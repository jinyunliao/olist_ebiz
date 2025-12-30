import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.utils.email import send_email_smtp

from slack_sdk.webhook import WebhookClient

# ========= 通知工具 =========
SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL", "")

def notify(message: str, **context):
    """Send a short notification to Slack (if configured) and email as fallback."""
    if SLACK_WEBHOOK_URL:
        try:
            WebhookClient(SLACK_WEBHOOK_URL).send(text=message)
        except Exception:
            pass
    # Optional email fallback
    try:
        send_email_smtp(to=['data-team@example.com'], subject='ETL Notification', html_content=message)
    except Exception:
        pass

def on_failure(context):
    ti = context.get('task_instance')
    exception = context.get('exception')
    msg = (
        f"❌ FAILURE: task={ti.task_id} dag={ti.dag_id} run={context.get('run_id')}\n"
        f"Exception: {exception}"
    )
    notify(msg)

def on_success(context):
    ti = context.get('task_instance')
    notify(f"✅ SUCCESS: task={ti.task_id} dag={ti.dag_id} run={context.get('run_id')}")

# ========= 业务步骤 =========
def extract_kaggle(**kwargs):
    """Placeholder extractor. In production, replace with S3/GCS ingestion and verification (row counts, hashes)."""
    # from scripts.extract_kaggle_olist import run as run_extract
    # run_extract(output_dir="/opt/airflow/data/olist_raw")
    pass 



default_args = {
    "owner": "data-eng",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "retry_exponential_backoff": True,
    "max_retry_delay": timedelta(minutes=30),
    "on_failure_callback": on_failure,
}

with DAG(
    dag_id="etl_dbt_olist",
    start_date=datetime(2025, 12, 30),
    schedule_interval="0 2 * * *",  # 每天 02:00
    catchup=False,
    default_args=default_args,
    tags=["olist", "dbt", "etl", "star-schema"]
) as dag:


    # dbt 运行（marts + staging 全部）
    DBT_DIR = "/opt/airflow/dbt"
    t_dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {DBT_DIR} && dbt deps",
        on_failure_callback=on_failure,
        on_success_callback=on_success,
    )

    t_dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"cd {DBT_DIR} && "
            f"dbt run --target {{{{ var.value.DBT_TARGET or env_var('DBT_TARGET', 'prod') }}}} "
            f"--vars '{{{{\"staging_schema\": env_var(\"DBT_STAGING_SCHEMA\", \"analytics_stg\"), "
            f"\"marts_schema\": env_var(\"DBT_SCHEMA\", \"analytics\")}}}}'"
        ),
        execution_timeout=timedelta(hours=2),
        sla=timedelta(hours=3),
        on_failure_callback=on_failure,
        on_success_callback=on_success,
    )

    t_dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_DIR} && dbt test --target $DBT_TARGET",
        on_failure_callback=on_failure,
        on_success_callback=on_success,
    )

    t_dbt_docs = BashOperator(
        task_id="dbt_docs",
        bash_command=f"cd {DBT_DIR} && dbt docs generate --target $DBT_TARGET",
        on_failure_callback=on_failure,
        on_success_callback=on_success,
    )

    # BI 刷新占位（根据平台实现：Tableau/PowerBI/Metabase API）
    t_bi_refresh = BashOperator(
        task_id="bi_refresh",
        bash_command="echo 'Trigger BI platform refresh via API placeholder'",
        on_success_callback=on_success,
    )

    t_dbt_deps >> t_dbt_run >> t_dbt_test >> t_dbt_docs >> t_bi_refresh
