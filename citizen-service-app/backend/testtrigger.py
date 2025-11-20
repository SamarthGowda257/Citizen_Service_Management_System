from app.database import engine
from sqlalchemy import text

with engine.connect() as conn:
    try:
        conn.execute(text("INSERT INTO Citizen (Name, Phone, Address) VALUES ('', '9999999999', 'Test City');"))
        conn.commit()
    except Exception as e:
        print("🔥 Trigger fired and blocked insert:", e)
