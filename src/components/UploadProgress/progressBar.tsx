import React from 'react';
import { LinearProgress, Divider, Box } from '@mui/material';
import { UPLOAD_STAGES } from 'constants/upload';

export function UploadProgressBar({ uploadStage, now }) {
    return (
        <Box mb={2}>
            {(uploadStage === UPLOAD_STAGES.READING_GOOGLE_METADATA_FILES ||
                uploadStage === UPLOAD_STAGES.EXTRACTING_METADATA ||
                uploadStage === UPLOAD_STAGES.UPLOADING) && (
                <LinearProgress
                    sx={{
                        height: '2px',
                        backgroundColor: 'transparent',
                    }}
                    variant="determinate"
                    value={now}
                />
            )}
            <Divider />
        </Box>
    );
}
