let chart = null

function getTickerInput ()
{
    return document.getElementById('ticker-input').value.toUpperCase();

}

async function fetchStock() {
    const ticker = getTickerInput();
    const errorDiv = document.getElementById('error-display');
    const priceDiv = document.getElementById('price-display');

    errorDiv.textContent= '';

    try {
        const response = await fetch(`/quote?ticker=${ticker}`);
        const data = await response.json();

        if (data.error)
        {
            errorDiv.textContent = data.error;
            return;
        }

        priceDiv.textContent = `${ticker}: $${data.price.toFixed(2)} ${data.currency}`;
        await loadHistory();
    } catch (err) {
        errorDiv.textContent = 'Failed to fetch stock data.';
    }
}
async function loadHistory() {
    const ticker = getTickerInput();
    const errorDiv = document.getElementById('error-display');
    errorDiv.textContent= '';

    try {
        const response = await fetch(`/history?ticker=${ticker}`);
        const data = await response.json();

        if(data.length == 0) {
            errorDiv.textContent = 'No history found. Click Fetch & Track first.';
            return;
        }

        const labels = data.map(r => new Date(r.timestamp));
        const prices = data.map(r => r.price);

        renderChart(ticker, labels, prices);
    } catch (err) {
        errorDiv.textContent = 'Failed to load history.';    
    }
}
function renderChart(ticker, labels, prices) {
    const ctx = document.getElementById('priceChart').getContext('2d');

    if (chart) {
        chart.destroy();
    }

    chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: `${ticker} Price (USD)`,
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
                        label: function(context) {
                            return `$${context.parsed.y.toFixed(2)}`;
                        }
                    }
                },
                legend: {
                    display: true
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
                        callback: function(value) {
                            return '$' + value.toFixed(2);
                        }
                    }
                }
            }
        }
    });
}