using System.Text;
using Microsoft.AspNetCore.Http;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Content sniffing for uploads (security finding M-08).
    ///
    /// Extension allow-lists alone are trivially bypassed: an attacker renames <c>payload.html</c> to
    /// <c>invoice.pdf</c> and the file is stored and later served from a trusted domain. This verifies
    /// the file's leading "magic bytes" actually match the claimed extension, so the declared type and
    /// real content agree.
    ///
    /// Formats with no reliable signature (e.g. <c>.txt</c>) cannot be sniffed; they are accepted, and
    /// remain protected by the extension allow-list plus the explicit Content-Type used when serving.
    /// </summary>
    public static class FileSignatureValidator
    {
        /// <summary>A magic-byte pattern and the offset it must appear at.</summary>
        private sealed record Signature(byte[] Magic, int Offset = 0);

        private static byte[] Ascii(string s) => Encoding.ASCII.GetBytes(s);

        private static readonly Dictionary<string, Signature[]> Signatures = new(StringComparer.OrdinalIgnoreCase)
        {
            // Images
            [".jpg"] = new[] { new Signature(new byte[] { 0xFF, 0xD8, 0xFF }) },
            [".jpeg"] = new[] { new Signature(new byte[] { 0xFF, 0xD8, 0xFF }) },
            [".png"] = new[] { new Signature(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }) },
            [".gif"] = new[] { new Signature(Ascii("GIF87a")), new Signature(Ascii("GIF89a")) },
            [".bmp"] = new[] { new Signature(Ascii("BM")) },

            // Documents
            [".pdf"] = new[] { new Signature(Ascii("%PDF")) },
            [".doc"] = new[] { new Signature(new byte[] { 0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1 }) },
            [".docx"] = new[] { new Signature(new byte[] { 0x50, 0x4B, 0x03, 0x04 }) }, // OOXML is a ZIP container

            // Audio
            [".mp3"] = new[]
            {
                new Signature(Ascii("ID3")),                       // ID3v2 tag
                new Signature(new byte[] { 0xFF, 0xFB }),          // MPEG-1 Layer 3 frame headers
                new Signature(new byte[] { 0xFF, 0xF3 }),
                new Signature(new byte[] { 0xFF, 0xF2 })
            },
            [".wav"] = new[] { new Signature(Ascii("RIFF")) },      // "WAVE" at offset 8 also checked below
            [".ogg"] = new[] { new Signature(Ascii("OggS")) },
            [".m4a"] = new[] { new Signature(Ascii("ftyp"), 4) },   // ISO-BMFF box type at offset 4
            [".aac"] = new[]
            {
                new Signature(new byte[] { 0xFF, 0xF1 }),           // ADTS
                new Signature(new byte[] { 0xFF, 0xF9 }),
                new Signature(Ascii("ADIF"))
            }
        };

        /// <summary>Longest signature offset+length we ever need to inspect.</summary>
        private const int HeaderBytesToRead = 16;

        /// <summary>
        /// True when the file's content matches its extension, or when the extension has no known
        /// signature to check against.
        /// </summary>
        public static bool Matches(IFormFile file, string extension)
        {
            if (file == null || file.Length == 0) return false;
            if (!Signatures.TryGetValue(extension, out var candidates)) return true; // unsniffable (e.g. .txt)

            var header = ReadHeader(file);
            if (header.Length == 0) return false;

            var matched = candidates.Any(sig => StartsWith(header, sig));
            if (!matched) return false;

            // RIFF is a generic container (also .avi/.webp) — confirm it is specifically WAVE.
            if (extension.Equals(".wav", StringComparison.OrdinalIgnoreCase))
                return StartsWith(header, new Signature(Ascii("WAVE"), 8));

            return true;
        }

        private static byte[] ReadHeader(IFormFile file)
        {
            using var stream = file.OpenReadStream();
            var buffer = new byte[HeaderBytesToRead];

            var read = 0;
            while (read < buffer.Length)
            {
                var n = stream.Read(buffer, read, buffer.Length - read);
                if (n == 0) break; // file shorter than the buffer
                read += n;
            }

            return read == buffer.Length ? buffer : buffer[..read];
        }

        private static bool StartsWith(byte[] header, Signature signature)
        {
            if (header.Length < signature.Offset + signature.Magic.Length) return false;

            for (var i = 0; i < signature.Magic.Length; i++)
            {
                if (header[signature.Offset + i] != signature.Magic[i]) return false;
            }

            return true;
        }
    }
}
