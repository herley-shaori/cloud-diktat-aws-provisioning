# =============================================================================
# Data Upload to S3 for Knowledge Base
# =============================================================================
# All coffee shop data is defined inline and uploaded to S3 using null_resource
# =============================================================================

resource "null_resource" "upload_knowledge_data" {
  depends_on = [
    aws_s3_bucket.knowledge_base,
    aws_s3_bucket_versioning.knowledge_base,
    aws_s3_bucket_policy.knowledge_base
  ]

  triggers = {
    bucket_id    = aws_s3_bucket.knowledge_base.id
    data_version = "v1.0.0" # Change this to re-upload data
  }

  provisioner "local-exec" {
    command = <<-EOT
      python3 -c '
import boto3
import json

s3 = boto3.client("s3", region_name="${local.region}")
bucket = "${aws_s3_bucket.knowledge_base.id}"

# =============================================================================
# MENU AND RECIPES DATA
# =============================================================================

menu_data = {
    "coffee_shop_name": "A Coffee Shop",
    "last_updated": "2024-01-15",
    "drinks": [
        {
            "name": "Espresso",
            "category": "Hot Coffee",
            "description": "A concentrated shot of pure coffee essence",
            "sizes": ["single", "double"],
            "prices": {"single": 25000, "double": 35000},
            "ingredients": ["18g finely ground coffee beans"],
            "preparation_time_minutes": 2,
            "recipe": {
                "steps": [
                    "Grind 18g of coffee beans to fine consistency",
                    "Distribute grounds evenly in portafilter",
                    "Tamp with 30lbs pressure",
                    "Lock portafilter into group head",
                    "Extract for 25-30 seconds",
                    "Target yield: 36ml with golden crema"
                ],
                "tips": [
                    "Water temperature should be 90-96°C",
                    "Pre-heat the cup",
                    "Clean portafilter between shots"
                ]
            },
            "caffeine_mg": 63,
            "calories": 3
        },
        {
            "name": "Americano",
            "category": "Hot Coffee",
            "description": "Espresso diluted with hot water for a milder taste",
            "sizes": ["small", "medium", "large"],
            "prices": {"small": 30000, "medium": 35000, "large": 40000},
            "ingredients": ["Double espresso", "Hot water (150-200ml)"],
            "preparation_time_minutes": 3,
            "recipe": {
                "steps": [
                    "Pull a double shot of espresso",
                    "Heat water to 85-90°C",
                    "Add hot water to cup first",
                    "Pour espresso over water",
                    "Serve immediately"
                ],
                "tips": [
                    "Water first preserves crema",
                    "Adjust water ratio to customer preference"
                ]
            },
            "caffeine_mg": 126,
            "calories": 6
        },
        {
            "name": "Cappuccino",
            "category": "Hot Coffee",
            "description": "Equal parts espresso, steamed milk, and milk foam",
            "sizes": ["small", "medium", "large"],
            "prices": {"small": 35000, "medium": 42000, "large": 48000},
            "ingredients": ["Double espresso", "Steamed milk (60ml)", "Milk foam (60ml)"],
            "preparation_time_minutes": 4,
            "recipe": {
                "steps": [
                    "Pull a double shot of espresso into cup",
                    "Steam milk to 65-70°C with thick microfoam",
                    "Pour steamed milk holding back foam",
                    "Spoon foam on top",
                    "Optional: dust with cocoa powder"
                ],
                "tips": [
                    "Traditional ratio is 1:1:1",
                    "Foam should be thick and velvety",
                    "Serve in a 180ml cup"
                ]
            },
            "caffeine_mg": 126,
            "calories": 120
        },
        {
            "name": "Latte",
            "category": "Hot Coffee",
            "description": "Espresso with steamed milk and light foam",
            "sizes": ["small", "medium", "large"],
            "prices": {"small": 38000, "medium": 45000, "large": 52000},
            "ingredients": ["Double espresso", "Steamed milk (200-250ml)", "Light foam"],
            "preparation_time_minutes": 4,
            "recipe": {
                "steps": [
                    "Pull double espresso into cup",
                    "Steam milk to 65-70°C with light microfoam",
                    "Pour milk from height, finish close for latte art",
                    "Create heart or rosetta pattern"
                ],
                "tips": [
                    "More milk than cappuccino",
                    "Foam should be silky, not too thick",
                    "Perfect for latte art"
                ]
            },
            "caffeine_mg": 126,
            "calories": 190
        },
        {
            "name": "Flat White",
            "category": "Hot Coffee",
            "description": "Double ristretto with velvety microfoam milk",
            "sizes": ["regular"],
            "prices": {"regular": 42000},
            "ingredients": ["Double ristretto", "Steamed milk (130ml)", "Microfoam"],
            "preparation_time_minutes": 4,
            "recipe": {
                "steps": [
                    "Pull double ristretto (shorter extraction)",
                    "Steam milk with velvety microfoam",
                    "Pour milk directly into espresso",
                    "Finish with thin layer of microfoam"
                ],
                "tips": [
                    "Ristretto is more concentrated than espresso",
                    "Served in 160ml cup",
                    "Stronger coffee flavor than latte"
                ]
            },
            "caffeine_mg": 130,
            "calories": 100
        },
        {
            "name": "Mocha",
            "category": "Hot Coffee",
            "description": "Espresso with chocolate and steamed milk",
            "sizes": ["small", "medium", "large"],
            "prices": {"small": 42000, "medium": 50000, "large": 58000},
            "ingredients": ["Double espresso", "Chocolate syrup (30ml)", "Steamed milk", "Whipped cream"],
            "preparation_time_minutes": 5,
            "recipe": {
                "steps": [
                    "Add chocolate syrup to cup",
                    "Pull double espresso and mix with chocolate",
                    "Steam milk to 65-70°C",
                    "Pour steamed milk over espresso",
                    "Top with whipped cream and chocolate drizzle"
                ],
                "tips": [
                    "Mix chocolate thoroughly with espresso",
                    "Can use dark or milk chocolate",
                    "Optional: add cocoa powder on top"
                ]
            },
            "caffeine_mg": 126,
            "calories": 360
        },
        {
            "name": "Iced Latte",
            "category": "Iced Coffee",
            "description": "Espresso with cold milk over ice",
            "sizes": ["medium", "large"],
            "prices": {"medium": 45000, "large": 52000},
            "ingredients": ["Double espresso", "Cold milk (200ml)", "Ice cubes"],
            "preparation_time_minutes": 3,
            "recipe": {
                "steps": [
                    "Fill glass with ice cubes",
                    "Pour cold milk over ice",
                    "Pull double espresso",
                    "Slowly pour espresso over milk"
                ],
                "tips": [
                    "Use full glass of ice",
                    "Pour espresso slowly for layered effect",
                    "Stir before drinking"
                ]
            },
            "caffeine_mg": 126,
            "calories": 130
        },
        {
            "name": "Cold Brew",
            "category": "Iced Coffee",
            "description": "Smooth, less acidic coffee steeped for 18-24 hours",
            "sizes": ["medium", "large"],
            "prices": {"medium": 40000, "large": 48000},
            "ingredients": ["Coarse ground coffee", "Cold filtered water", "Ice"],
            "preparation_time_minutes": 2,
            "recipe": {
                "steps": [
                    "Use pre-prepared cold brew concentrate",
                    "Fill glass with ice",
                    "Pour cold brew concentrate (1:2 ratio with water)",
                    "Add cold water to desired strength"
                ],
                "tips": [
                    "Cold brew is made in advance (18-24 hour steep)",
                    "Ratio: 1 part coffee to 8 parts water for concentrate",
                    "Store concentrate for up to 2 weeks"
                ]
            },
            "caffeine_mg": 200,
            "calories": 5
        },
        {
            "name": "Caramel Macchiato",
            "category": "Specialty",
            "description": "Vanilla latte marked with espresso and caramel drizzle",
            "sizes": ["medium", "large"],
            "prices": {"medium": 52000, "large": 60000},
            "ingredients": ["Double espresso", "Vanilla syrup (20ml)", "Steamed milk", "Caramel sauce"],
            "preparation_time_minutes": 5,
            "recipe": {
                "steps": [
                    "Add vanilla syrup to cup",
                    "Pour steamed milk over syrup",
                    "Pull double espresso",
                    "Pour espresso through foam to mark it",
                    "Drizzle caramel sauce in crosshatch pattern"
                ],
                "tips": [
                    "Macchiato means marked in Italian",
                    "Espresso is poured last",
                    "Can be served hot or iced"
                ]
            },
            "caffeine_mg": 126,
            "calories": 280
        },
        {
            "name": "Matcha Latte",
            "category": "Non-Coffee",
            "description": "Japanese green tea powder with steamed milk",
            "sizes": ["small", "medium", "large"],
            "prices": {"small": 40000, "medium": 48000, "large": 55000},
            "ingredients": ["Matcha powder (2g)", "Hot water (30ml)", "Steamed milk (200ml)"],
            "preparation_time_minutes": 4,
            "recipe": {
                "steps": [
                    "Sift matcha powder into cup",
                    "Add hot water (70-80°C)",
                    "Whisk until smooth with no lumps",
                    "Steam milk to 65°C",
                    "Pour steamed milk over matcha"
                ],
                "tips": [
                    "Always sift matcha to prevent lumps",
                    "Use bamboo whisk or milk frother",
                    "Can be sweetened with honey"
                ]
            },
            "caffeine_mg": 70,
            "calories": 150
        },
        {
            "name": "Hot Chocolate",
            "category": "Non-Coffee",
            "description": "Rich chocolate drink with steamed milk",
            "sizes": ["small", "medium", "large"],
            "prices": {"small": 35000, "medium": 42000, "large": 48000},
            "ingredients": ["Chocolate sauce (40ml)", "Steamed milk (250ml)", "Whipped cream"],
            "preparation_time_minutes": 3,
            "recipe": {
                "steps": [
                    "Add chocolate sauce to cup",
                    "Steam milk to 65-70°C",
                    "Pour milk and stir to combine",
                    "Top with whipped cream",
                    "Dust with cocoa powder"
                ],
                "tips": [
                    "Use premium chocolate for best taste",
                    "Can add marshmallows",
                    "Temperature should not exceed 70°C"
                ]
            },
            "caffeine_mg": 5,
            "calories": 320
        },
        {
            "name": "Chai Latte",
            "category": "Non-Coffee",
            "description": "Spiced tea concentrate with steamed milk",
            "sizes": ["small", "medium", "large"],
            "prices": {"small": 38000, "medium": 45000, "large": 52000},
            "ingredients": ["Chai concentrate (60ml)", "Steamed milk (200ml)"],
            "preparation_time_minutes": 3,
            "recipe": {
                "steps": [
                    "Heat chai concentrate",
                    "Steam milk to 65-70°C",
                    "Combine chai and milk in cup",
                    "Dust with cinnamon"
                ],
                "tips": [
                    "Chai contains cinnamon, cardamom, ginger, cloves",
                    "Adjust sweetness to preference",
                    "Can be served iced"
                ]
            },
            "caffeine_mg": 50,
            "calories": 180
        }
    ],
    "modifiers": {
        "milk_options": [
            {"name": "Whole Milk", "extra_cost": 0},
            {"name": "Skim Milk", "extra_cost": 0},
            {"name": "Oat Milk", "extra_cost": 8000},
            {"name": "Almond Milk", "extra_cost": 8000},
            {"name": "Soy Milk", "extra_cost": 5000}
        ],
        "extras": [
            {"name": "Extra Shot", "cost": 10000},
            {"name": "Vanilla Syrup", "cost": 8000},
            {"name": "Caramel Syrup", "cost": 8000},
            {"name": "Hazelnut Syrup", "cost": 8000},
            {"name": "Whipped Cream", "cost": 5000}
        ]
    }
}

s3.put_object(
    Bucket=bucket,
    Key="menu/drinks_menu.json",
    Body=json.dumps(menu_data, indent=2),
    ContentType="application/json"
)
print("Uploaded menu data")

# =============================================================================
# STANDARD OPERATING PROCEDURES (SOPs)
# =============================================================================

sop_data = {
    "document_type": "Standard Operating Procedures",
    "version": "2.1",
    "last_updated": "2024-01-10",
    "sections": [
        {
            "title": "Opening Procedures",
            "steps": [
                "Arrive 30 minutes before opening time",
                "Disarm security system using staff code",
                "Turn on all lights and HVAC system",
                "Turn on espresso machine (15 min warm-up required)",
                "Check refrigerator temperatures (must be below 4°C)",
                "Prepare fresh milk pitchers",
                "Grind fresh coffee beans for the day",
                "Set up POS system and count opening cash drawer",
                "Check inventory levels and note any shortages",
                "Clean and sanitize all work surfaces",
                "Put out pastry display items",
                "Unlock front door at opening time"
            ]
        },
        {
            "title": "Closing Procedures",
            "steps": [
                "Stop accepting orders 15 minutes before closing",
                "Clean espresso machine (backflush with cleaner)",
                "Empty and clean drip trays",
                "Wash all milk pitchers and equipment",
                "Wipe down all surfaces with food-safe sanitizer",
                "Empty trash and replace bags",
                "Mop floors with approved cleaning solution",
                "Store all perishables in refrigerator",
                "Count cash drawer and prepare deposit",
                "Complete end-of-day sales report",
                "Turn off espresso machine and grinder",
                "Set security alarm",
                "Lock all doors and ensure building is secure"
            ]
        },
        {
            "title": "Food Safety Guidelines",
            "procedures": [
                {
                    "name": "Temperature Control",
                    "details": [
                        "Refrigerator must maintain temperature below 4°C",
                        "Hot beverages must be served at 65-70°C",
                        "Cold beverages must be served below 5°C",
                        "Check temperatures every 4 hours and log"
                    ]
                },
                {
                    "name": "Milk Handling",
                    "details": [
                        "Use milk within 24 hours of opening",
                        "Never mix old milk with new milk",
                        "Discard milk left at room temperature for over 2 hours",
                        "Clean milk pitchers after each use"
                    ]
                },
                {
                    "name": "Hand Washing",
                    "details": [
                        "Wash hands before starting work",
                        "Wash after handling money",
                        "Wash after touching face, hair, or phone",
                        "Wash after cleaning tasks",
                        "Use soap for minimum 20 seconds"
                    ]
                },
                {
                    "name": "Cross-Contamination Prevention",
                    "details": [
                        "Use separate equipment for allergen-free drinks",
                        "Clean steam wand between different milk types",
                        "Store allergens separately",
                        "Always ask about allergies"
                    ]
                }
            ]
        },
        {
            "title": "Cleaning Schedule",
            "daily_tasks": [
                "Clean espresso machine group heads after each drink",
                "Backflush machine every 4 hours",
                "Wipe down counters every hour",
                "Clean steam wand after every use",
                "Empty grounds container when 3/4 full",
                "Sanitize touch points (door handles, POS) every 2 hours"
            ],
            "weekly_tasks": [
                "Deep clean espresso machine with Cafiza",
                "Clean grinder burrs and hopper",
                "Descale steam wand",
                "Clean refrigerator interior",
                "Wash floor mats",
                "Clean windows and glass surfaces"
            ],
            "monthly_tasks": [
                "Professional espresso machine service check",
                "Deep clean grinder",
                "Inventory count",
                "Review and update procedures"
            ]
        }
    ]
}

s3.put_object(
    Bucket=bucket,
    Key="sop/standard_procedures.json",
    Body=json.dumps(sop_data, indent=2),
    ContentType="application/json"
)
print("Uploaded SOP data")

# =============================================================================
# FREQUENTLY ASKED QUESTIONS (FAQ)
# =============================================================================

faq_data = {
    "document_type": "Frequently Asked Questions",
    "categories": [
        {
            "name": "General Information",
            "questions": [
                {
                    "question": "What are your opening hours?",
                    "answer": "We are open Monday to Friday from 7:00 AM to 9:00 PM, and Saturday-Sunday from 8:00 AM to 10:00 PM. Hours may vary by location."
                },
                {
                    "question": "Do you have WiFi?",
                    "answer": "Yes! Free WiFi is available at all locations. Ask our barista for the password."
                },
                {
                    "question": "Can I bring my laptop to work?",
                    "answer": "Absolutely! We welcome remote workers. We have power outlets available at most tables."
                },
                {
                    "question": "Do you have parking?",
                    "answer": "Parking availability varies by location. Our Sudirman branch has basement parking, Kemang has street parking, and Senayan is located in a mall with parking facilities."
                }
            ]
        },
        {
            "name": "Menu & Orders",
            "questions": [
                {
                    "question": "What is the difference between a latte and cappuccino?",
                    "answer": "A cappuccino has equal parts espresso, steamed milk, and foam (1:1:1 ratio), making it more foamy and stronger in coffee flavor. A latte has more steamed milk with just a thin layer of foam, resulting in a creamier, milder taste."
                },
                {
                    "question": "Do you have decaf options?",
                    "answer": "Yes, we offer decaf espresso for all our espresso-based drinks. Just ask for decaf when ordering. Note that decaf still contains small amounts of caffeine."
                },
                {
                    "question": "What non-dairy milk options do you have?",
                    "answer": "We offer oat milk, almond milk, and soy milk as alternatives to dairy. Oat milk and almond milk are +Rp 8,000, soy milk is +Rp 5,000."
                },
                {
                    "question": "Can I customize my drink?",
                    "answer": "Yes! You can add extra shots, choose different milk options, add flavored syrups (vanilla, caramel, hazelnut), adjust sweetness level, or request extra hot/iced."
                },
                {
                    "question": "Do you have sugar-free syrups?",
                    "answer": "Yes, we have sugar-free vanilla and sugar-free caramel options at no extra charge."
                },
                {
                    "question": "What is your strongest coffee drink?",
                    "answer": "Our Cold Brew has the highest caffeine content at approximately 200mg per serving. For hot drinks, you can always add extra shots to any espresso-based beverage."
                }
            ]
        },
        {
            "name": "Allergies & Dietary",
            "questions": [
                {
                    "question": "Do you have gluten-free options?",
                    "answer": "All our coffee and tea drinks are naturally gluten-free. However, our pastries may contain gluten. Please check with staff for specific items."
                },
                {
                    "question": "Are your drinks vegan-friendly?",
                    "answer": "Many of our drinks can be made vegan by substituting dairy milk with oat, almond, or soy milk. Please note that some syrups may contain dairy."
                },
                {
                    "question": "Do you have allergen information?",
                    "answer": "Yes, we have detailed allergen information available. Please ask our staff about specific allergens. Common allergens in our drinks include dairy, soy, and tree nuts (in almond milk)."
                }
            ]
        },
        {
            "name": "Loyalty & Payment",
            "questions": [
                {
                    "question": "Do you have a loyalty program?",
                    "answer": "Yes! Download our app to join our loyalty program. Earn 1 point for every Rp 10,000 spent. 100 points = free drink of your choice."
                },
                {
                    "question": "What payment methods do you accept?",
                    "answer": "We accept cash, all major credit/debit cards, GoPay, OVO, DANA, and ShopeePay."
                },
                {
                    "question": "Can I order ahead?",
                    "answer": "Yes! Use our mobile app to order ahead and skip the line. Orders are typically ready within 5-10 minutes."
                }
            ]
        }
    ]
}

s3.put_object(
    Bucket=bucket,
    Key="faq/customer_faq.json",
    Body=json.dumps(faq_data, indent=2),
    ContentType="application/json"
)
print("Uploaded FAQ data")

# =============================================================================
# SUPPLIER INFORMATION
# =============================================================================

supplier_data = {
    "document_type": "Supplier Directory",
    "suppliers": [
        {
            "id": "SUP001",
            "name": "Java Coffee Beans Co.",
            "category": "Coffee Beans",
            "products": [
                {"name": "House Blend", "origin": "Java, Indonesia", "roast": "Medium"},
                {"name": "Single Origin Ethiopian", "origin": "Yirgacheffe, Ethiopia", "roast": "Light"},
                {"name": "Espresso Blend", "origin": "Brazil/Colombia", "roast": "Dark"}
            ],
            "ordering": {
                "minimum_order": "5 kg",
                "lead_time_days": 2,
                "delivery_days": ["Monday", "Wednesday", "Friday"],
                "payment_terms": "Net 30"
            },
            "contact": {
                "sales_rep": "Budi Santoso",
                "note": "Contact through official channels only"
            },
            "quality_notes": "All beans are specialty grade, roasted within 2 weeks of delivery"
        },
        {
            "id": "SUP002",
            "name": "Fresh Dairy Farm",
            "category": "Dairy & Alternatives",
            "products": [
                {"name": "Whole Milk", "type": "Fresh", "unit": "1L bottle"},
                {"name": "Skim Milk", "type": "Fresh", "unit": "1L bottle"},
                {"name": "Oat Milk", "brand": "Oatly", "unit": "1L carton"}
            ],
            "ordering": {
                "minimum_order": "20 liters",
                "lead_time_days": 1,
                "delivery_days": ["Daily except Sunday"],
                "payment_terms": "COD"
            },
            "contact": {
                "sales_rep": "Dewi Lestari",
                "note": "Contact through official channels only"
            },
            "quality_notes": "Milk delivered daily, check expiry dates on receipt"
        },
        {
            "id": "SUP003",
            "name": "Sweet Supplies Inc.",
            "category": "Syrups & Sauces",
            "products": [
                {"name": "Vanilla Syrup", "brand": "Monin", "unit": "750ml"},
                {"name": "Caramel Syrup", "brand": "Monin", "unit": "750ml"},
                {"name": "Chocolate Sauce", "brand": "Ghirardelli", "unit": "1.5L"},
                {"name": "Hazelnut Syrup", "brand": "Monin", "unit": "750ml"}
            ],
            "ordering": {
                "minimum_order": "6 bottles",
                "lead_time_days": 3,
                "delivery_days": ["Tuesday", "Thursday"],
                "payment_terms": "Net 14"
            },
            "contact": {
                "sales_rep": "Ahmad Wijaya",
                "note": "Contact through official channels only"
            }
        },
        {
            "id": "SUP004",
            "name": "Pack & Go Supplies",
            "category": "Packaging",
            "products": [
                {"name": "Paper Cups 8oz", "material": "Double wall", "unit": "500 pcs/box"},
                {"name": "Paper Cups 12oz", "material": "Double wall", "unit": "500 pcs/box"},
                {"name": "Paper Cups 16oz", "material": "Double wall", "unit": "500 pcs/box"},
                {"name": "Lids", "material": "PLA compostable", "unit": "1000 pcs/box"},
                {"name": "Stirrers", "material": "Wooden", "unit": "1000 pcs/box"}
            ],
            "ordering": {
                "minimum_order": "2 boxes per item",
                "lead_time_days": 5,
                "delivery_days": ["Monday"],
                "payment_terms": "Net 30"
            },
            "contact": {
                "sales_rep": "Siti Rahayu",
                "note": "Contact through official channels only"
            },
            "quality_notes": "All packaging is eco-friendly and compostable"
        }
    ]
}

s3.put_object(
    Bucket=bucket,
    Key="suppliers/supplier_directory.json",
    Body=json.dumps(supplier_data, indent=2),
    ContentType="application/json"
)
print("Uploaded supplier data")

# =============================================================================
# TROUBLESHOOTING GUIDE
# =============================================================================

troubleshooting_data = {
    "document_type": "Equipment Troubleshooting Guide",
    "equipment": [
        {
            "name": "Espresso Machine",
            "model": "La Marzocco Linea Mini",
            "common_issues": [
                {
                    "problem": "No water coming out of group head",
                    "possible_causes": ["Water tank empty", "Pump failure", "Clogged group head"],
                    "solutions": [
                        "Check and refill water tank",
                        "Check pump is switched on",
                        "Backflush with clean water",
                        "If problem persists, call technician"
                    ],
                    "urgency": "High"
                },
                {
                    "problem": "Coffee tastes bitter",
                    "possible_causes": ["Over-extraction", "Water too hot", "Coffee ground too fine"],
                    "solutions": [
                        "Reduce extraction time (aim for 25-30 seconds)",
                        "Check water temperature (should be 90-96°C)",
                        "Adjust grinder to coarser setting",
                        "Check coffee freshness"
                    ],
                    "urgency": "Medium"
                },
                {
                    "problem": "Coffee tastes sour",
                    "possible_causes": ["Under-extraction", "Water too cold", "Coffee ground too coarse"],
                    "solutions": [
                        "Increase extraction time",
                        "Check water temperature",
                        "Adjust grinder to finer setting",
                        "Ensure proper tamping pressure (30lbs)"
                    ],
                    "urgency": "Medium"
                },
                {
                    "problem": "No crema on espresso",
                    "possible_causes": ["Stale coffee beans", "Grind too coarse", "Low pressure"],
                    "solutions": [
                        "Use fresher coffee beans (roasted within 2-3 weeks)",
                        "Adjust grinder finer",
                        "Check machine pressure gauge (should read 9 bars)",
                        "Check portafilter basket for damage"
                    ],
                    "urgency": "Medium"
                },
                {
                    "problem": "Steam wand not producing steam",
                    "possible_causes": ["Boiler not heated", "Clogged steam tip", "Steam valve issue"],
                    "solutions": [
                        "Wait for boiler to fully heat (check indicator)",
                        "Clear steam tip with pin",
                        "Purge steam wand before use",
                        "Call technician if valve is stuck"
                    ],
                    "urgency": "High"
                },
                {
                    "problem": "Machine displaying error code",
                    "possible_causes": ["Various - refer to manual"],
                    "solutions": [
                        "Note the error code",
                        "Turn machine off and wait 30 seconds",
                        "Turn back on and observe",
                        "If error persists, call technician with error code"
                    ],
                    "urgency": "High"
                }
            ],
            "maintenance_tips": [
                "Backflush with water after every 10 drinks",
                "Backflush with Cafiza every end of day",
                "Wipe steam wand after EVERY use",
                "Empty drip tray when half full",
                "Professional service every 3 months"
            ]
        },
        {
            "name": "Coffee Grinder",
            "model": "Mazzer Mini Electronic",
            "common_issues": [
                {
                    "problem": "Inconsistent grind",
                    "possible_causes": ["Worn burrs", "Bean hopper almost empty", "Static buildup"],
                    "solutions": [
                        "Check burr condition (replace if worn)",
                        "Keep hopper at least 1/4 full",
                        "Add small drop of water to beans (RDT technique)",
                        "Clean grinder chute of buildup"
                    ],
                    "urgency": "Medium"
                },
                {
                    "problem": "Grinder making unusual noise",
                    "possible_causes": ["Foreign object", "Motor issue", "Burrs touching"],
                    "solutions": [
                        "Stop immediately and check for foreign objects",
                        "Remove hopper and check burr chamber",
                        "Adjust burrs if touching",
                        "Call technician if motor sounds wrong"
                    ],
                    "urgency": "High"
                }
            ]
        },
        {
            "name": "Refrigerator",
            "common_issues": [
                {
                    "problem": "Temperature above 4°C",
                    "possible_causes": ["Door left open", "Overloaded", "Thermostat issue"],
                    "solutions": [
                        "Check door seal is intact",
                        "Remove excess items for airflow",
                        "Check thermostat setting",
                        "Call technician if problem persists",
                        "IMPORTANT: Discard perishables if temp exceeded for 2+ hours"
                    ],
                    "urgency": "Critical"
                }
            ]
        }
    ],
    "emergency_contacts": {
        "note": "For equipment emergencies, contact the shift manager first",
        "escalation": "If unable to resolve, contact the branch manager"
    }
}

s3.put_object(
    Bucket=bucket,
    Key="troubleshooting/equipment_guide.json",
    Body=json.dumps(troubleshooting_data, indent=2),
    ContentType="application/json"
)
print("Uploaded troubleshooting data")

# =============================================================================
# BRANCH INFORMATION
# =============================================================================

branch_data = {
    "document_type": "Branch Information",
    "branches": [
        {
            "id": "sudirman",
            "name": "A Coffee Shop - Sudirman",
            "address": "Jl. Jenderal Sudirman No. 123, Jakarta Pusat",
            "hours": {
                "weekday": "07:00 - 21:00",
                "weekend": "08:00 - 22:00"
            },
            "features": ["WiFi", "Power Outlets", "Meeting Room", "Parking"],
            "capacity": 60
        },
        {
            "id": "kemang",
            "name": "A Coffee Shop - Kemang",
            "address": "Jl. Kemang Raya No. 45, Jakarta Selatan",
            "hours": {
                "weekday": "07:00 - 22:00",
                "weekend": "08:00 - 23:00"
            },
            "features": ["WiFi", "Power Outlets", "Outdoor Seating", "Pet Friendly"],
            "capacity": 40
        },
        {
            "id": "senayan",
            "name": "A Coffee Shop - Senayan City",
            "address": "Senayan City Mall, Lt. 1, Jakarta Selatan",
            "hours": {
                "weekday": "10:00 - 22:00",
                "weekend": "10:00 - 22:00"
            },
            "features": ["WiFi", "Power Outlets", "Mall Parking"],
            "capacity": 50
        }
    ]
}

s3.put_object(
    Bucket=bucket,
    Key="branches/branch_info.json",
    Body=json.dumps(branch_data, indent=2),
    ContentType="application/json"
)
print("Uploaded branch data")

print("All knowledge base data uploaded successfully!")
'
    EOT
  }

  # CRITICAL: Delete all objects before bucket destruction
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      python3 -c '
import boto3
s3 = boto3.resource("s3", region_name="${local.region}")
bucket = s3.Bucket("${self.triggers.bucket_id}")
bucket.object_versions.all().delete()
bucket.objects.all().delete()
print("Deleted all objects from bucket")
' || echo "Bucket may already be empty or deleted"
    EOT
  }
}

# -----------------------------------------------------------------------------
# Sync Knowledge Base after data upload
# -----------------------------------------------------------------------------

resource "null_resource" "sync_knowledge_base" {
  depends_on = [
    null_resource.upload_knowledge_data,
    aws_bedrockagent_data_source.s3
  ]

  triggers = {
    data_source_id    = aws_bedrockagent_data_source.s3.data_source_id
    knowledge_base_id = aws_bedrockagent_knowledge_base.coffee_shop.id
    data_version      = null_resource.upload_knowledge_data.triggers.data_version
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Starting knowledge base sync..."
      aws bedrock-agent start-ingestion-job \
        --knowledge-base-id ${aws_bedrockagent_knowledge_base.coffee_shop.id} \
        --data-source-id ${aws_bedrockagent_data_source.s3.data_source_id} \
        --region ${local.region}

      echo "Ingestion job started. It may take a few minutes to complete."
    EOT
  }
}
