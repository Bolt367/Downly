# Base image with Python
FROM python:3.13-slim

# Install ffmpeg
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Set working directory inside container
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy all code into container
COPY . .

# Expose the port your app runs on
EXPOSE 5000

# Run your Flask app
CMD ["python", "api.py"]
