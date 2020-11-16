{
  "swagger" : "2.0",
  "info" : {
    "version" : "2020-11-04T13:28:45Z",
    "title" : "${title}"
  },
  "basePath" : "/${environment}",
  "schemes" : [ "https" ],
  "paths" : {
    "/export/{consignmentId+}" : {
      "post" : {
        "consumes" : [ "application/json" ],
        "produces" : [ "application/json" ],
        "parameters" : [ {
          "name" : "consignmentId",
          "in" : "path",
          "required" : true,
          "type" : "string"
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "schema" : {
              "$ref" : "#/definitions/Empty"
            }
          }
        },
        "security" : [ {
          "lambda" : [ ]
        } ],
        "x-amazon-apigateway-integration" : {
          "credentials" : "${role_arn}",
          "uri" : "arn:aws:apigateway:eu-west-2:states:action/StartExecution",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.header.Accept-Encoding" : "'identity'",
            "integration.request.header.Content-Type" : "'application/x-amz-json-1.1'"
          },
          "requestTemplates" : {
            "application/json" : "{\"input\": \"{\\\"consignmentId\\\": \\\"$input.params('consignmentId')\\\"}\",\"stateMachineArn\": \"${state_machine_arn}\"}"
          },
          "passthroughBehavior" : "when_no_templates",
          "httpMethod" : "POST",
          "cacheNamespace" : "pddmb7",
          "cacheKeyParameters" : [ "method.request.path.consignmentId" ],
          "type" : "aws"
        }
      }
    }
  },
  "securityDefinitions" : {
    "lambda" : {
      "type" : "apiKey",
      "name" : "Authorization",
      "in" : "header",
      "x-amazon-apigateway-authtype" : "custom",
      "x-amazon-apigateway-authorizer" : {
        "authorizerUri" : "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${lambda_arn}/invocations",
        "authorizerResultTtlInSeconds" : 0,
        "type" : "token"
      }
    }
  },
  "definitions" : {
    "Empty" : {
      "type" : "object",
      "title" : "Empty Schema"
    }
  }
}