# Use the official Python image from the Docker Hub
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory
WORKDIR /app

# Copy the requirements file and install dependencies
COPY backend/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the code
COPY backend /app/

# Expose the port Flask runs on
EXPOSE 5000

# Start the Flask application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]