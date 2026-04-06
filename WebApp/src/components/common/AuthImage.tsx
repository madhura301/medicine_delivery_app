import { useState, useEffect, useRef } from 'react';
import { Box, CircularProgress, Typography } from '@mui/material';
import { BrokenImage as BrokenImageIcon } from '@mui/icons-material';
import type { BoxProps } from '@mui/material';
import api from '../../api/axiosInstance';

interface AuthImageProps extends Omit<BoxProps, 'component' | 'src' | 'alt'> {
  src: string;
  alt: string;
  onImageClick?: () => void;
}

/** Image component that fetches via the axios instance (with JWT auth) and displays as a blob URL. */
export default function AuthImage({ src, alt, onImageClick, ...boxProps }: AuthImageProps) {
  const [blobUrl, setBlobUrl] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const blobRef = useRef<string>('');

  useEffect(() => {
    let cancelled = false;

    api
      .get(src, { responseType: 'blob' })
      .then((res) => {
        if (!cancelled) {
          const url = URL.createObjectURL(res.data);
          blobRef.current = url;
          setBlobUrl(url);
          setLoading(false);
        }
      })
      .catch(() => {
        if (!cancelled) {
          setError(true);
          setLoading(false);
        }
      });

    return () => {
      cancelled = true;
      if (blobRef.current) URL.revokeObjectURL(blobRef.current);
    };
  }, [src]);

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: 200 }}>
        <CircularProgress size={32} />
      </Box>
    );
  }

  if (error) {
    return (
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: 200, bgcolor: '#f5f5f5', borderRadius: 2 }}>
        <BrokenImageIcon sx={{ fontSize: 48, color: 'grey.400' }} />
        <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>Failed to load image</Typography>
      </Box>
    );
  }

  return (
    <Box
      component="img"
      src={blobUrl}
      alt={alt}
      onClick={onImageClick}
      {...boxProps}
    />
  );
}
