


# SmartQueryBI

**Version:** 1.0  
**Description:** SmartQueryBI is an AI microservice using LLaMA to convert natural language into secure SQL for Supabase. It supports SELECT, JOIN, UNION, WINDOW queries while blocking harmful operations like INSERT, DELETE, UPDATE, CREATE, and leverages in-memory caching for fast, safe, and optimized data access.

---

## Features

- **Natural Language → SQL:** Seamless conversion via LLM integration.
- **Secure SQL Execution:** Protected by strict allow/deny rules to prevent malicious queries.
- **SELECT & INSERT Support:** Designed for both analytics and controlled data loading.
- **Advanced SQL Capabilities:** Full support for CTEs, window functions, complex joins, and aggregations.
- **In-memory Caching:** High performance with a 60-second TTL (Time-To-Live).
- **Monitoring APIs:** Built-in health checks and cache status monitoring.
- **Production-Ready:** Built with a high-performance FastAPI backend.




## Architecture & Workflow

```text
    [User Request]
          │
          ▼
    [LLM SQL Generator]
          │
          ▼
    [Validated SQL]
          │
          ▼
    [Supabase RPC execute_sql]
          │
          ▼
    [Query Result ]
          │
          ▼
    [API Response + Cache]

```

---

## Core Components

### `generate_visualization_query(question: str)`

* Converts natural language input to optimized SQL.
* Enforces allowed SQL operations at the generation level.
* Optimized for performance and readability.

### `execute_llm_select_query(sql: str)`

* Executes SQL via a secure Supabase RPC.
* Blocks destructive operations (DELETE, DROP, etc.).
* Returns structured JSON results.

### Cache Layer

* **TTL:** 60 seconds.
* **Functions:** `get_cache`, `set_cache`, `invalidate_cache`.

---

## API Endpoints

### System

| Method | Endpoint | Description |
| --- | --- | --- |
| **GET** | `/` | Root / System status |
| **GET** | `/health` | Health & cache status |

### Query Execution

| Method | Endpoint | Description |
| --- | --- | --- |
| **POST** | `/dynamic-query/server-cache` | LLM → SQL → Execution with caching |

### Cache Management

| Method | Endpoint | Description |
| --- | --- | --- |
| **POST** | `/cache/invalidate` | Clear all cached entries |
| **POST** | `/cache/invalidate/{description}` | Clear a specific cache entry |

---

## Supabase Data Model

### Dimensions

* **product_dim:** `product_id`, `product_name`, `category`, `brand`, `supplier`, `cost_price`
* **employee_dim:** `employee_id`, `first_name`, `last_name`, `role`, `hire_date`, `department`
* **store_dim:** `store_id`, `store_name`, `location`, `region`, `manager_id`
* **customer_dim:** `customer_id`, `first_name`, `last_name`, `email`, `phone`, `city`, `country`
* **date_dim:** `date_id`, `year`, `month`, `day`, `quarter`, `weekday`

### Facts

* **sales_fact:** `sale_id`, `date_id`, `product_id`, `employee_id`, `store_id`, `customer_id`, `quantity`, `unit_price`, `discount`, `total_amount`

---

## Security Model

| ✅ Allowed Operations | ❌ Blocked Operations |
| --- | --- |
| `SELECT` | `DELETE` |
| `JOIN` / `LEFT JOIN` | `UPDATE` |
| `WITH` (CTEs) | `DROP` / `TRUNCATE` |
| Window Functions (`OVER`, `RANK`) | `CREATE` / `ALTER` |
| Aggregations (`SUM`, `AVG`) | `GRANT` / `REVOKE` |
| `CASE`, `CAST`, `COALESCE` | `INSERT`  |

---

## Installation

```bash
# Clone the repository
git clone [https://github.com/kamal-badawi/SmartQueryBI-Microservice.git](https://github.com/kamal-badawi/SmartQueryBI-Microservice.git)
cd SmartQueryBI-Microservice

# Setup virtual environment
python -m venv venv
source venv/bin/activate  # Linux / macOS
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

```

### Environment Variables

Create a `.env` file in the root directory:

```env
GROQ_API_KEY=your_groq_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key

```

---

## Usage

```bash
# Start the server
uvicorn main:app --reload

```

* **Swagger UI:** `http://localhost:8000/docs`
* **ReDoc:** `http://localhost:8000/redoc`

---

## Example Requests

**Endpoint:** `POST /dynamic-query/server-cache`

```json
// Example 1: Simple Filter
{
  "description": "Which employees were hired after 2019?"
}

// Example 2: Advanced Analytics
{
  "description": "For each employee, show monthly total sales, their rank within the department, and the department average sales"
}

// Example 3: Comparison
{
  "description": "Compare the sales of employees this month compared to last month."
}

// Example 4: Cumulative Analysis
{
  "description": "Calculate the accumulated sales per product this month by day."
}

// Example 5: Hierarchy Performance
{
  "description": "Analyze sales performance by department, team, and employee and show percentage contribution at each level."
}


// Example 6: Creative Llama
{
"description": "Tell me something creative about my data."
}
```

---

## Best Practices

1. **Exploration:** Always use `LIMIT` when performing exploratory queries.
2. **Complexity:** Use CTEs (Common Table Expressions) for multi-step logic to improve readability.
3. **Testing:** Always test new query descriptions in a staging environment.
4. **Auditing:** Ensure your fact tables include timestamps for better auditing.

---

## License

This project is licensed under the MIT License.

---

## Author

Kamal Badawi