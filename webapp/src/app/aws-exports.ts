const awsconfig = {
    aws_project_region: "us-east-1",
    // aws_cognito_identity_pool_id: "us-east-1:d2b7e98f-e4a7-49bf-851f-92f7e49a17cb",
    aws_cognito_region: "us-east-1",
    aws_user_pools_id: "us-east-1_nQyRF3b4j",
    aws_user_pools_web_client_id: "4u9bnstroa37fldal8pv66qjof",
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