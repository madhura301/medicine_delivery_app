namespace MedicineDelivery.Application.Interfaces
{
    public interface IFileStorageService
    {
        /// <summary>
        /// Uploads a file from the given stream to the specified relative path.
        /// </summary>
        /// <returns>The stored relative path.</returns>
        Task<string> UploadAsync(Stream fileStream, string relativePath, CancellationToken cancellationToken = default);

        /// <summary>
        /// Opens a file for reading. Returns null if the file does not exist.
        /// </summary>
        Task<Stream?> OpenReadAsync(string relativePath, CancellationToken cancellationToken = default);

        /// <summary>
        /// Deletes the file at the specified relative path.
        /// </summary>
        /// <returns>True if the file was deleted; false if it did not exist.</returns>
        Task<bool> DeleteAsync(string relativePath, CancellationToken cancellationToken = default);

        /// <summary>
        /// Checks whether a file exists at the specified relative path.
        /// </summary>
        Task<bool> ExistsAsync(string relativePath, CancellationToken cancellationToken = default);

        /// <summary>
        /// Returns a publicly accessible URL for the file at the given relative path.
        /// </summary>
        string GetPublicUrl(string relativePath);
    }
}
