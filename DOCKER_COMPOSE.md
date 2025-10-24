# Running Excalidraw Complete with Docker Compose and Cloudflare R2

This guide explains how to run Excalidraw Complete using Docker Compose with Cloudflare R2 as the storage backend. The UI build is now integrated directly into the main Dockerfile for a simplified setup.

## Prerequisites

1. Docker and Docker Compose installed on your system
2. A Cloudflare account with R2 enabled
3. An R2 bucket created
4. R2 API credentials (Access Key ID and Secret Access Key)

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/fahmiauliarahman/excalidraw-complete.git --recursive
   cd excalidraw-complete
   ```

2. Copy the example environment file and configure it:
   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file with your Cloudflare R2 credentials:
   ```
   # Storage configuration for Cloudflare R2
   STORAGE_TYPE=s3
   S3_BUCKET_NAME=your-r2-bucket-name
   
   # AWS credentials for Cloudflare R2
   AWS_ACCESS_KEY_ID=your-r2-access-key
   AWS_SECRET_ACCESS_KEY=your-r2-secret-key
   AWS_REGION=auto
   
   # Custom endpoint for Cloudflare R2
   # Replace YOUR_ACCOUNT_ID with your actual Cloudflare account ID
   AWS_ENDPOINT_URL_S3=https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com
   
   # Application configuration
   LOGLEVEL=info
   ```

   To find your Cloudflare Account ID:
   - Log in to the Cloudflare dashboard
   - On the right sidebar, you'll see your Account ID

4. Build and run the application with Docker Compose:
   ```bash
   docker-compose up -d
   ```
   Note: The first build may take longer as it needs to build both the frontend and backend components in a single container.

5. Access Excalidraw Complete at `https://draw.fahmiar.blog`

## Build Process

The Docker Compose setup uses a multi-stage build process:

1. First, it builds the frontend UI using Node.js and yarn
2. Then it builds the Go backend with the frontend files included
3. Finally, it creates a lightweight Alpine image with just the compiled application

This ensures that the frontend is properly embedded in the final container and the application can serve the UI files directly.

Note: The first build may take longer as it needs to compile both the frontend and backend. Subsequent builds will be faster due to Docker's layer caching.

## Managing the Application

- To view logs: `docker-compose logs -f excalidraw-complete`
- To stop the application: `docker-compose down`
- To rebuild after changes: `docker-compose up --build`
- To force a clean rebuild: `docker-compose build --no-cache`

## Troubleshooting

### Build Issues

If you encounter build errors, try the following:

1. **Clean build**: `docker-compose build --no-cache`
2. **Check Node.js version**: The frontend requires Node.js 18.x
3. **Check yarn.lock**: Ensure the yarn.lock file is present in the excalidraw directory
4. **Frontend build errors**: Check that all required files are present in the excalidraw directory
5. **cross-env not found**: This is now handled by installing cross-env globally in the Dockerfile
6. **Entry module not found**: Fixed by changing the working directory to excalidraw-app before running the build command
7. **Module not found (clsx)**: Fixed by copying the packages/excalidraw package.json to ensure all workspace dependencies are installed
8. **JavaScript heap out of memory**: If you encounter a "JavaScript heap out of memory" error during the frontend build, it's because the Node.js process doesn't have enough memory allocated. This is fixed by increasing the heap size limit with the `--max-old-space-size` flag in the Dockerfile.

```bash
# The Dockerfile has been updated to use:
# NODE_OPTIONS="--max-old-space-size=4096" yarn build:app:docker
# If you still encounter this issue, try rebuilding with --no-cache
docker-compose build --no-cache excalidraw-complete
```

### Runtime Issues

1. **Port conflicts**: Make sure port 3002 is not in use
2. **S3/R2 connection**: Verify your S3 credentials and bucket configuration
3. **Permission issues**: Check that the application has permission to write to the frontend directory

If you encounter issues with Cloudflare R2:

1. Verify your credentials are correct
2. Ensure your bucket exists and is accessible
3. Check that your account ID is correct in the endpoint URL
4. Make sure your R2 token has the necessary permissions

If you encounter build issues:

1. Ensure you have enough disk space and Docker resources allocated
2. The first build may take longer as it compiles both frontend and backend
3. Check the build logs for any specific error messages

For more information about Cloudflare R2, refer to the [official documentation](https://developers.cloudflare.com/r2/).