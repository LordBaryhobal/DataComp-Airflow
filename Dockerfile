FROM apache/airflow:2.11.0-python3.9
USER root
# Add the Python environment
RUN python -m pip install -U --no-cache-dir pip && \
    python -m pip install --no-cache-dir "scikit-learn>=1.2"

COPY plugins_dev/mc-notifier/dist/airflow_provider_minecraft-0.1.0-py3-none-any.whl /tmp/
RUN python -m pip install /tmp/airflow_provider_minecraft-0.1.0-py3-none-any.whl

# Back to the airflow user
USER airflow
