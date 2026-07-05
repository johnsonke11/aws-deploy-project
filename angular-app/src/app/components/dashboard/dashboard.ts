
import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {Chart, registerables } from 'chart.js';
import 'chartjs-adapter-date-fns';
import { StockService, StockHistory, StockQuote } from '../../services/stock';

Chart.register(...registerables);
@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.css',
})

export class DashboardComponent implements OnInit, AfterViewInit{

  @ViewChild('priceChart') priceChartRef!: ElementRef;

  ticker: string = 'AAPL';
  currentQuote: StockQuote | null = null;
  errorMessage: string = '';
  chart: Chart | null = null;

  constructor(private stockService: StockService) {}

  ngOnInit(): void {}

  ngAfterViewInit(): void {
    this.loadHistory();
  }
  fetchStock(): void {
    this.errorMessage = '';
    this.stockService.getQuote(this.ticker.toUpperCase()).subscribe({
      next: (data) => {
        this.currentQuote = data;
        this.loadHistory();
      },
      error: () => {
        this.errorMessage = 'Failed to fetch stock data.';
      }
    });
  }

  loadHistory(): void {
    this.errorMessage = '';
    this.stockService.getHistory(this.ticker.toUpperCase()).subscribe({
      next: (data) => {
        if (data.length === 0) {
          this.errorMessage = 'No history found. Click Fetch & Track first.';
          return;
        }
        this.renderChart(data);
      },
      error: () => {
        this.errorMessage = 'Failed to load history.';
      }
    });
  }

  renderChart(data: StockHistory[]): void {
    const labels = data.map(r => new Date(r.timestamp));
    const prices = data.map(r => r.price);

    if (this.chart) {
      this.chart.destroy();
    }

    const canvas = this.priceChartRef.nativeElement;
    const existingChart = Chart.getChart(canvas);
    if (existingChart) {
      existingChart.destroy();
    }


    this.chart = new Chart(this.priceChartRef.nativeElement, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: `${this.ticker} Price (USD)`,
          data: prices,
          borderColor: '#007bff',
          backgroundColor: 'rgba(0, 123, 255, 0.1)',
          borderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 7,
          fill: true,
          tension: 0.3
        }]
      },
      options: {
        responsive: true,
        interaction: {
          mode: 'index',
          intersect: false
        },
        plugins: {
          tooltip: {
            callbacks: {
              label: (context) => {
                if (context.parsed.y === null) return '';
                return `$${context.parsed.y.toFixed(2)}`;
              }
            }
          }
        },
        scales: {
          x: {
            type: 'time',
            time: {
              unit: 'minute',
              displayFormats: {
                minute: 'MMM d, h:mm a'
              }
            },
            title: {
              display: true,
              text: 'Time'
            }
          },
          y: {
            title: {
              display: true,
              text: 'Price (USD)'
            },
            ticks: {
              callback: (value) => '$' + Number(value).toFixed(2)
            }
          }
        }
      }
    });
  }
}

