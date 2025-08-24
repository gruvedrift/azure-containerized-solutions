# Python minimal
FROM python:3.13.0

# Working directory
WORKDIR /app

# Copy files to Work directory
COPY app.py requirements.txt ./

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose for port 5050
EXPOSE 5000

# Run the application
CMD ["python3", "app.py"]

