import ballerina/http;
import ballerina/log;

http:ListenerConfiguration serviceConfig = {
    httpVersion: "2.0",
    secureSocket: {
        keyStore: {
            path: "${BALLERINA_HOME}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
};

http:ClientConfiguration clientConfig = {
    httpVersion: "2.0",
    secureSocket: {
        trustStore: {
            path: "${BALLERINA_HOME}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        },
        verifyHostname: false
    }
};

http:Client nettyEP = new("https://netty:8688", clientConfig);

@http:ServiceConfig { basePath: "/passthrough" }
service passthroughService on new http:Listener(9090, serviceConfig) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {

        var response = nettyEP->forward("/service/EchoService", clientRequest);

        if (response is http:Response) {
            var result = caller->respond(response);
        } else {
            log:printError("Error at h2_h2_passthrough", err = response);
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(response.detail()?.message);
            var result = caller->respond(res);
        }
    }
}
