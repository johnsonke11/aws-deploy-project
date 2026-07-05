import { Observable } from 'rxjs';
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment.development';

export interface StockQuote {
    ticker: string;
    price: number;
    currency: string;
}
export interface StockHistory {
    id: number;
    ticker: string;
    price: number;
    currency: string;
    timestamp: string;
}

@Injectable({
    providedIn: 'root'
})
export class StockService{
    private apiUrl = environment.apiURL;

    constructor(private http: HttpClient) {}

    getQuote(ticker: string): Observable<StockQuote> {
        return this.http.get<StockQuote>(`${this.apiUrl}/quote?ticker=${ticker}`);
    }
    getHistory(ticker: string): Observable<StockHistory[]> {
        return this.http.get<StockHistory[]>(`${this.apiUrl}/history?ticker=${ticker}`);
    }
}