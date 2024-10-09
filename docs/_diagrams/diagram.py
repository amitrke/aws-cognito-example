from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS, EKS, Lambda
from diagrams.aws.database import Redshift
from diagrams.aws.integration import SQS
from diagrams.aws.storage import S3

with Diagram("Web Service", show=False):
    ELB("lb") >> EC2("web") >> RDS("userdb")


with Diagram("Event Processing", show=False):
    source = EKS("k8s source")

    with Cluster("Event Flows"):
        with Cluster("Event Workers"):
            workers = [ECS("worker1"),
                       ECS("worker2"),
                       ECS("worker3")]

        queue = SQS("event queue")

        with Cluster("Processing"):
            handlers = [Lambda("proc1"),
                        Lambda("proc2"),
                        Lambda("proc3")]

    store = S3("events store")
    dw = Redshift("analytics")

    source >> workers >> queue >> handlers
    handlers >> store
    handlers >> dw

'''
Diagram for Application that uses REST API secured with Cognito User Pool
Cognito User Pool uses Google as Identity Provider
An Angular App is used as the frontend
'''
from diagrams import Cluster, Diagram

from diagrams.aws.security import Cognito
from diagrams.aws.mobile import APIGateway
from diagrams.aws.compute import Lambda
from diagrams.aws.integration import SNS
from diagrams.aws.database import Dynamodb
from diagrams.onprem.client import User

with Diagram("Angular Cognito Application", show=False):
    user = User("user")
    with Cluster("AWS"):
        cognito = Cognito("user pool")
        with Cluster("API"):
            api_gateway = APIGateway("api gateway")
            authorizer = Lambda("authorizer")
            api_gateway >> authorizer
        with Cluster("Backend"):
            handlers = [Lambda("fn1"),
                        Lambda("fn2"),
                        Lambda("fn3")]
            queue = SNS("sns")
            db = Dynamodb("dynamodb")
        with Cluster("Identity Provider"):
            google = User("google")
            cognito << google
    user >> cognito >> authorizer
    authorizer >> api_gateway >> handlers
    handlers >> queue >> db
    handlers >> db
    handlers >> google

