from flask import Blueprint, jsonify, request, render_template
from app.models import db, StockPrice
import yfinance as yf

main = Blueprint("main", __name__)

@main.route("/")
def home():
    return jsonify({"status": "Stock price trader is running"}), 200

@main.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@main.route("/quote")
def quote():
    ticker = request.args.get("ticker", "AAPL").upper()

    try:
        stock = yf.Ticker(ticker)
        info = stock.info

        price = info.get("currentPrice") or info.get("regularMarketPrice")
        currency = info.get("currency","USD")

        if not price:
            return jsonify({"error": f"Could not fetch price for {ticker}"}), 400
        
        record = StockPrice(
            ticker = ticker,
            price = price,
            currency = currency
        )
        db.session.add(record)
        db.session.commit()

        return jsonify({
            "ticker": ticker,
            "price": price,
            "currency": currency

        }), 200
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@main.route("/history")
def history():
    
    ticker = request.args.get("ticker", "AAPL").upper()

    records = StockPrice.query.filter_by(ticker=ticker)\
            .order_by(StockPrice.timestamp.desc())\
            .limit(10)\
            .all()
    return jsonify([r.to_dict() for r in records]), 200

@main.route("/dashboard")
def dashboard():
    ticker = request.args.get("ticker", "APPL").upper()

    record = StockPrice.query.filter_by(ticker=ticker)\
            .order_by(StockPrice.timestamp.desc())\
            .first()
    current_price = record.price if record else None
    currency = record.currency if record else None

    return render_template(
        "dashboard.html",
        ticker= ticker,
        current_price =current_price,
        currency = currency
    )