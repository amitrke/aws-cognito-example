const awsconfig = {
    aws_project_region: "us-east-1",
    // aws_cognito_identity_pool_id: "us-east-1:4731dd9a-f803-4b09-9b1b-f64579d6637b",
    aws_cognito_region: "us-east-1",
    aws_user_pools_id: "us-east-1_eiOnkS3Pz",
    aws_user_pools_web_client_id: "5kc191bl44ha7gvk398j4uuc2d",
    oauth: {
        domain: "amrke-myapp.auth.us-east-1.amazoncognito.com",
        scope: [
            "openid",
            "email",
            "profile"
        ],
        redirectSignIn: "https://app.subnext.com/",
        redirectSignOut: "https://app.subnext.com/",
        responseType: "code"
    }
};

export default awsconfig;