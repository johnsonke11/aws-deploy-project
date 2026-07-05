from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timezone

db = SQLAlchemy()

class StockPrice(db.Model):
    __tablename__ = "stock_prices"
    
    id = db.Column(db.Integer, primary_key= True)
    ticker = db.Column(db.String(10), nullable= False)
    price = db.Column(db.Float(), nullable = False)
    currency= db.Column(db.String(10), nullable= False)
    timestamp = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def to_dict(self):
        return{
            "id": self.id,
            "ticker": self.ticker,
            "price": self.price,
            "currency": self.currency,
            "timestamp": self.timestamp.isoformat()

        }
        
    