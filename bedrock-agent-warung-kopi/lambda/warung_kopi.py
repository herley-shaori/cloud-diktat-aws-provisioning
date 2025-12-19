"""
Warung Kopi Lambda Function
Handles menu and stock queries for Bedrock Agent
"""

import json


def lambda_handler(event, context):
    """Main handler for Bedrock Agent action group"""

    print(f"Received event: {json.dumps(event)}")

    # Extract action from Bedrock Agent event
    action = event.get("actionGroup", "")
    api_path = event.get("apiPath", "")
    http_method = event.get("httpMethod", "")
    parameters = event.get("parameters", [])

    # Convert parameters list to dict
    params_dict = {}
    for param in parameters:
        params_dict[param.get("name")] = param.get("value")

    # Route to appropriate handler
    if api_path == "/menu" and http_method == "GET":
        response_body = get_menu()
    elif api_path == "/stock" and http_method == "GET":
        item = params_dict.get("item", "")
        response_body = get_stock(item)
    else:
        response_body = {"error": f"Unknown action: {api_path}"}

    # Format response for Bedrock Agent
    response = {
        "messageVersion": "1.0",
        "response": {
            "actionGroup": action,
            "apiPath": api_path,
            "httpMethod": http_method,
            "httpStatusCode": 200,
            "responseBody": {
                "application/json": {
                    "body": json.dumps(response_body)
                }
            }
        }
    }

    print(f"Returning response: {json.dumps(response)}")
    return response


def get_menu():
    """Return static menu list"""
    return {
        "menu": [
            {"name": "Kopi Susu", "price": 25000},
            {"name": "Americano", "price": 22000},
            {"name": "Latte", "price": 28000},
            {"name": "Matcha Latte", "price": 30000}
        ],
        "currency": "IDR"
    }


def get_stock(item: str):
    """Return static stock information"""
    return {
        "item": item,
        "stock": 10,
        "available": True
    }
