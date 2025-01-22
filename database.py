import psycopg
from psycopg import sql

# Database connection parameters
# conn_params = "postgres://citus:cs11@2025@c-database-distribution.swexueucpdy7rz.postgres.cosmos.azure.com:5432/citus?sslmode=require"
conn_params = {
    'dbname': 'platform_test',
    'user': 'platform',
    'password': 'platform',
    'host': 'localhost',
    'port': 5433,
}

conn_params_two = {
    'dbname': 'platform_test',
    'user': 'platform',
    'password': 'platform',
    'host': 'localhost',
    'port': 5432,
}
# SQL statements to create tables
create_table_queries = [
    """
    CREATE TABLE IF NOT EXISTS  companies (
        id bigserial PRIMARY KEY,
        name text NOT NULL,
        image_url text,
        created_at timestamp without time zone NOT NULL,
        updated_at timestamp without time zone NOT NULL
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS  campaigns (
        id bigserial,
        company_id bigint REFERENCES companies (id),
        name text NOT NULL,
        cost_model text NOT NULL,
        state text NOT NULL,
        monthly_budget bigint,
        blacklisted_site_urls text[],
        created_at timestamp without time zone NOT NULL,
        updated_at timestamp without time zone NOT NULL,
        PRIMARY KEY (company_id, id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS  ads (
        id bigserial,
        company_id bigint,
        campaign_id bigint,
        name text NOT NULL,
        image_url text,
        target_url text,
        impressions_count bigint DEFAULT 0,
        clicks_count bigint DEFAULT 0,
        created_at timestamp without time zone NOT NULL,
        updated_at timestamp without time zone NOT NULL,
        PRIMARY KEY (company_id, id),
        FOREIGN KEY (company_id, campaign_id)
            REFERENCES campaigns (company_id, id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS  clicks (
        id bigserial,
        company_id bigint,
        ad_id bigint,
        clicked_at timestamp without time zone NOT NULL,
        site_url text NOT NULL,
        cost_per_click_usd numeric(20,10),
        user_ip inet NOT NULL,
        user_data jsonb NOT NULL,
        PRIMARY KEY (company_id, id),
        FOREIGN KEY (company_id, ad_id)
            REFERENCES ads (company_id, id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS impressions (
        id bigserial,
        company_id bigint,
        ad_id bigint,
        seen_at timestamp without time zone NOT NULL,
        site_url text NOT NULL,
        cost_per_impression_usd numeric(20,10),
        user_ip inet NOT NULL,
        user_data jsonb NOT NULL,
        PRIMARY KEY (company_id, id),
        FOREIGN KEY (company_id, ad_id)
            REFERENCES ads (company_id, id)
    )
    """
]

# Sample data to insert into tables
insert_data_queries = [
    """
    INSERT INTO ads (company_id, campaign_id, name, image_url, target_url, impressions_count, clicks_count, created_at, updated_at)
    VALUES 
    (1, 1, 'Ad 1', 'http://example.com/ad1.png', 'http://example.com/target1', 100, 10, now(), now()),
    (2, 2, 'Ad 2', 'http://example.com/ad2.png', 'http://example.com/target2', 200, 20, now(), now())
    """,
    """
    INSERT INTO clicks (company_id, ad_id, clicked_at, site_url, cost_per_click_usd, user_ip, user_data)
    VALUES 
    (1, 1, now(), 'http://example.com/site1', 0.5, '192.168.1.1', '{"user": "data1"}'),
    (2, 2, now(), 'http://example.com/site2', 0.75, '192.168.1.2', '{"user": "data2"}')
    """,
    """
    INSERT INTO impressions (company_id, ad_id, seen_at, site_url, cost_per_impression_usd, user_ip, user_data)
    VALUES 
    (1, 1, now(), 'http://example.com/site1', 0.1, '192.168.1.1', '{"user": "data1"}'),
    (2, 2, now(), 'http://example.com/site2', 0.15, '192.168.1.2', '{"user": "data2"}')
    """
]

def create_tables(conn):
    with conn.cursor() as cur:
        for query in create_table_queries:
            cur.execute(query)
        conn.commit()

def insert_data(conn):
    with conn.cursor() as cur:
        for query in insert_data_queries:
            cur.execute(query)
        conn.commit()

def main():
    try:
        with psycopg.connect(**conn_params) as conn:
            create_tables(conn)
            insert_data(conn)
            print("Tables created and data inserted successfully.")

        with psycopg.connect(**conn_params_two) as conn:
            create_tables(conn)
            insert_data(conn)
    except Exception as e:
        print(f"An error occurred: {e}")
        raise e

if __name__ == "__main__":
    main()