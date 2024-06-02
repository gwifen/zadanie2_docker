const express = require('express');
const fs = require('fs');
const package = require('./package.json')

// Inicjalizacja aplikacji Express
const app = express();
const port = 3000;

// Funkcja tworząca logi
function logServerStart() {
    const author = package.author
    const logMessage = `Server started at ${new Date().toISOString()}, by ${author}, listening on port ${port}\n`;
    fs.appendFileSync('log.txt', logMessage);
}


// Funkcja pobierająca adres IP klienta
function getIPAddress(req, res, next) {
    fetch('https://api.ipify.org?format=json')
        .then(response => response.json())
        .then(data => {
            req.ipAddress = data.ip;
            next();
        })
        .catch(error => {
            console.error('Error fetching IP address:', error);
            res.status(500).send('Internal Server Error');
        });
}

// Funkcja pobierająca aktualną datę i godzinę w strefie czasowej klienta
function getClientDateTime(req, res) {
    fetch('https://worldtimeapi.org/api/ip/' + req.ipAddress)
        .then(response => response.json())
        .then(data => {
            res.send(`
                <div>Adres IP klienta: ${req.ipAddress}</div>
                <div>Data i czas w strefie czasowej klienta: ${data.datetime}</div>
            `);
        })
        .catch(error => {
            console.error('Error fetching client date and time:', error);
            res.status(500).send('Internal Server Error');
        });
}

// Middleware do obsługi zapytania
app.get('/', getIPAddress, getClientDateTime);

// Uruchomienie serwera i logowanie startu
app.listen(port, () => {
    logServerStart();
    console.log(`Server is listening on port ${port}, press Ctrl+C to stop server`);
});
