# A recipe for a container that runs the booking service.
# Build it from the course folder, after train.py has written the model:
#     docker build -f all_experiments/lab10_end_to_end_project/booking_project/Dockerfile -t booking-service .
#     docker run -p 8000:8000 booking-service

# 1. Start from a small image that already has the right Python.
FROM python:3.13-slim
WORKDIR /app

# 2. Install the exact package versions first, so this slow step is reused until requirements.txt changes.
COPY all_experiments/lab10_end_to_end_project/booking_project/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy the code the service needs, then the model and its card.
COPY all_experiments/lab10_end_to_end_project/booking_project/bookings.py \
     all_experiments/lab10_end_to_end_project/booking_project/serve.py ./
COPY models/booking_cancellation.joblib models/booking_cancellation_card.json ./models/

# 4. Tell the service where things are, and start it. Inside a container it must listen on 0.0.0.0.
ENV MODEL_PATH=/app/models/booking_cancellation.joblib HOST=0.0.0.0 PORT=8000
EXPOSE 8000
CMD ["python", "serve.py"]
