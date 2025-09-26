from airflow import DAG
from airflow.operators.bash import BashOperator
from minecraft_provider.notifications.minecraft import MinecraftNotifier

with DAG(dag_id="minecraft-test", schedule_interval=None) as dag:
    task1 = BashOperator(
        task_id="task1",
        bash_command="echo Hello World!",
        on_success_callback=MinecraftNotifier(
            rcon_conn_id="my_server",
            message="Task {{ task_instance.task_id }} finished with state {{ task_instance.state }} at {{ ts }}"
        )
    )

    task2 = BashOperator(
        task_id="task2",
        bash_command="exit 1"
    )

    task1 >> task2
