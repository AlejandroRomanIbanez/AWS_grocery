# Use the official Python image
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file and install dependencies
COPY backend/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the code
COPY backend /app/

# Make sure the script is executable
RUN chmod +x /app/manage.py

# Expose the port Flask runs on
EXPOSE 5000

# Start the application properly
CMD ["sh", "-c", "python manage.py db upgrade && python manage.py seed_database && gunicorn --bind 0.0.0.0:5000 run:app"]
