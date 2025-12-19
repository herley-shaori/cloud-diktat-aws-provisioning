# =============================================================================
# Lambda Function for Bedrock Agent Actions
# =============================================================================

# Inline Lambda code using archive_file
data "archive_file" "agent_actions" {
  type        = "zip"
  output_path = "${path.module}/agent_actions.zip"

  source {
    content  = <<-PYTHON
import json
import random
from datetime import datetime, timedelta

def lambda_handler(event, context):
    """
    Lambda handler for Coffee Shop AI Agent actions.
    Handles inventory checks, purchase orders, and queue management.
    """
    print(f"Received event: {json.dumps(event)}")

    # Parse the Bedrock Agent request
    action_group = event.get('actionGroup', '')
    function = event.get('function', '')
    parameters = event.get('parameters', [])

    # Convert parameters list to dict for easier access
    params = {p['name']: p['value'] for p in parameters}

    # Mock inventory data for different branches
    inventory_data = {
        "sudirman": {
            "milk": {"quantity": 15, "unit": "liters", "min_stock": 5},
            "coffee_beans": {"quantity": 5000, "unit": "grams", "min_stock": 2000},
            "sugar": {"quantity": 2000, "unit": "grams", "min_stock": 500},
            "oat_milk": {"quantity": 8, "unit": "liters", "min_stock": 3},
            "chocolate_syrup": {"quantity": 1500, "unit": "ml", "min_stock": 500},
            "vanilla_syrup": {"quantity": 1200, "unit": "ml", "min_stock": 500},
            "cups_small": {"quantity": 200, "unit": "pieces", "min_stock": 50},
            "cups_medium": {"quantity": 180, "unit": "pieces", "min_stock": 50},
            "cups_large": {"quantity": 150, "unit": "pieces", "min_stock": 50},
            "ice": {"quantity": 10, "unit": "kg", "min_stock": 3}
        },
        "kemang": {
            "milk": {"quantity": 8, "unit": "liters", "min_stock": 5},
            "coffee_beans": {"quantity": 3000, "unit": "grams", "min_stock": 2000},
            "sugar": {"quantity": 1500, "unit": "grams", "min_stock": 500},
            "oat_milk": {"quantity": 4, "unit": "liters", "min_stock": 3},
            "chocolate_syrup": {"quantity": 800, "unit": "ml", "min_stock": 500},
            "vanilla_syrup": {"quantity": 600, "unit": "ml", "min_stock": 500},
            "cups_small": {"quantity": 120, "unit": "pieces", "min_stock": 50},
            "cups_medium": {"quantity": 100, "unit": "pieces", "min_stock": 50},
            "cups_large": {"quantity": 80, "unit": "pieces", "min_stock": 50},
            "ice": {"quantity": 5, "unit": "kg", "min_stock": 3}
        },
        "senayan": {
            "milk": {"quantity": 20, "unit": "liters", "min_stock": 5},
            "coffee_beans": {"quantity": 8000, "unit": "grams", "min_stock": 2000},
            "sugar": {"quantity": 3000, "unit": "grams", "min_stock": 500},
            "oat_milk": {"quantity": 12, "unit": "liters", "min_stock": 3},
            "chocolate_syrup": {"quantity": 2000, "unit": "ml", "min_stock": 500},
            "vanilla_syrup": {"quantity": 1800, "unit": "ml", "min_stock": 500},
            "cups_small": {"quantity": 300, "unit": "pieces", "min_stock": 50},
            "cups_medium": {"quantity": 280, "unit": "pieces", "min_stock": 50},
            "cups_large": {"quantity": 250, "unit": "pieces", "min_stock": 50},
            "ice": {"quantity": 15, "unit": "kg", "min_stock": 3}
        }
    }

    # Supplier data
    suppliers = {
        "SUP001": {"name": "Java Coffee Beans Co.", "items": ["coffee_beans"], "lead_time_days": 2},
        "SUP002": {"name": "Fresh Dairy Farm", "items": ["milk", "oat_milk"], "lead_time_days": 1},
        "SUP003": {"name": "Sweet Supplies Inc.", "items": ["sugar", "chocolate_syrup", "vanilla_syrup"], "lead_time_days": 3},
        "SUP004": {"name": "Pack & Go Supplies", "items": ["cups_small", "cups_medium", "cups_large"], "lead_time_days": 5}
    }

    response_body = {}

    # Handle different functions
    if function == "checkStock":
        branch_id = params.get('branch_id', 'sudirman').lower()
        item_name = params.get('item_name', '').lower().replace(' ', '_')

        if branch_id not in inventory_data:
            response_body = {
                "status": "error",
                "message": f"Branch '{branch_id}' not found. Available branches: sudirman, kemang, senayan"
            }
        elif item_name and item_name not in inventory_data[branch_id]:
            response_body = {
                "status": "error",
                "message": f"Item '{item_name}' not found in inventory"
            }
        elif item_name:
            item = inventory_data[branch_id][item_name]
            status = "OK" if item["quantity"] > item["min_stock"] else "LOW"
            response_body = {
                "status": "success",
                "branch": branch_id,
                "item": item_name,
                "quantity": item["quantity"],
                "unit": item["unit"],
                "minimum_stock": item["min_stock"],
                "stock_status": status,
                "needs_reorder": item["quantity"] <= item["min_stock"]
            }
        else:
            # Return all inventory for branch
            branch_inventory = []
            for item_name, item in inventory_data[branch_id].items():
                status = "OK" if item["quantity"] > item["min_stock"] else "LOW"
                branch_inventory.append({
                    "item": item_name,
                    "quantity": item["quantity"],
                    "unit": item["unit"],
                    "stock_status": status
                })
            response_body = {
                "status": "success",
                "branch": branch_id,
                "inventory": branch_inventory
            }

    elif function == "createPurchaseOrder":
        items = params.get('items', '')
        supplier_id = params.get('supplier_id', 'SUP001')
        branch_id = params.get('branch_id', 'sudirman')

        if supplier_id not in suppliers:
            response_body = {
                "status": "error",
                "message": f"Supplier '{supplier_id}' not found"
            }
        else:
            supplier = suppliers[supplier_id]
            po_number = f"PO-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000, 9999)}"
            estimated_delivery = (datetime.now() + timedelta(days=supplier["lead_time_days"])).strftime('%Y-%m-%d')

            response_body = {
                "status": "success",
                "po_number": po_number,
                "supplier": supplier["name"],
                "supplier_id": supplier_id,
                "items_ordered": items,
                "branch": branch_id,
                "order_date": datetime.now().strftime('%Y-%m-%d %H:%M'),
                "estimated_delivery": estimated_delivery,
                "message": f"Purchase order {po_number} created successfully"
            }

    elif function == "getQueueLength":
        branch_id = params.get('branch_id', 'sudirman').lower()

        # Simulate queue data based on time of day
        hour = datetime.now().hour
        base_queue = {"sudirman": 5, "kemang": 3, "senayan": 8}

        # Peak hours adjustment
        if 7 <= hour <= 9 or 12 <= hour <= 14:
            multiplier = 2.5
        elif 15 <= hour <= 17:
            multiplier = 1.5
        else:
            multiplier = 1.0

        queue_length = int(base_queue.get(branch_id, 4) * multiplier + random.randint(-2, 3))
        queue_length = max(0, queue_length)

        wait_time = queue_length * 3  # 3 minutes per customer average

        response_body = {
            "status": "success",
            "branch": branch_id,
            "current_queue": queue_length,
            "estimated_wait_minutes": wait_time,
            "busy_level": "High" if queue_length > 10 else "Medium" if queue_length > 5 else "Low",
            "timestamp": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        }

    elif function == "getSupplierInfo":
        supplier_id = params.get('supplier_id', '')

        if supplier_id and supplier_id in suppliers:
            supplier = suppliers[supplier_id]
            response_body = {
                "status": "success",
                "supplier_id": supplier_id,
                "name": supplier["name"],
                "items_supplied": supplier["items"],
                "lead_time_days": supplier["lead_time_days"]
            }
        else:
            # Return all suppliers
            response_body = {
                "status": "success",
                "suppliers": [
                    {"id": sid, **sdata} for sid, sdata in suppliers.items()
                ]
            }

    else:
        response_body = {
            "status": "error",
            "message": f"Unknown function: {function}"
        }

    # Format response for Bedrock Agent
    return {
        'response': {
            'actionGroup': action_group,
            'function': function,
            'functionResponse': {
                'responseBody': {
                    'TEXT': {
                        'body': json.dumps(response_body, indent=2)
                    }
                }
            }
        }
    }
PYTHON
    filename = "index.py"
  }
}

resource "aws_lambda_function" "agent_actions" {
  function_name    = "${local.name_prefix}-agent-actions"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = 30
  memory_size      = 256
  filename         = data.archive_file.agent_actions.output_path
  source_code_hash = data.archive_file.agent_actions.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = local.common_tags
}

# Permission for Bedrock to invoke Lambda
resource "aws_lambda_permission" "bedrock_invoke" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.agent_actions.function_name
  principal     = "bedrock.amazonaws.com"
  source_arn    = "arn:aws:bedrock:${local.region}:${local.account_id}:agent/*"
}
