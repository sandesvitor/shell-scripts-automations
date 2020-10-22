#!/bin/bash

echo "<<< Socket IO Messager with Python 3.8 and Javascript (Webpack) >>>"
echo " >>>> Starting installation:"
echo "Please inform project's folder name: "
read PROJECT_NAME

if [ ! -d $PROJECT_NAME ]; then
    echo "###### CREATING PROJECT '$PROJECT_NAME' BOILERPLATE ######"
    echo "SERVER SIDE :: handling main folders and files"

    mkdir server; cd server
    
    echo "<<< Creating Main app.py (server side application) >>>"
    cat > app.py <<EOF
from aiohttp import web
import socketio
import json

app = web.Application()
io = socketio.AsyncServer(cors_allowed_origins=[])
io.attach(app)
routes = web.RouteTableDef()

all_messages = []

@io.event
async def connect(sid, environ):
    print(f"[io.on('connect') - new socket [{sid}]")
    print("Sending session id to user...")
    await io.emit('whoAmI', sid, room=sid)


@io.on("sendMessage")
async def handle_message(sid, message):
    message_dict = {"id": sid, "message": message}
    all_messages.append(message_dict)

    await io.emit("roomData", json.dumps(message_dict))


@io.event
async def disconnect(sid):
    print(f"[io.on('disconnect') - socket [{sid}] disconnected ")



@routes.get("/")
async def index(request):
    return web.Response(text="<h1>Server Running</h1>", content_type="text/html")

app.add_routes(routes)


if __name__ == "__main__":
    web.run_app(app, port=5000)
EOF

    echo "Ready to install Pipenv and other dependencys ::"
    pip install pipenv
    pipenv install pylint autopep8 aiohttp python-socketio

    cd ..
    echo "CLIENT SIDE :: handling main folders and files"
    mkdir client; cd client
    mkdir src; cd src
    mkdir styles; mkdir main

    echo "<<< Creating index.html (client side boilerplate html5) >>>"
    cat > index.html <<EOF
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simple Messager</title>
</head>

<body>
    <header class="header">
        <h1>Simple Socket IO Messanger</h1>
    </header>
    <div class="messanger-container">
        <div class="messages-display">
            <!-- Your messages will be generated dynamicly here =) -->
        </div>
        <div class="messages-input">
            <input type="text">
            <button>Send</button>
        </div>
    </div>

</body>

</html>
EOF

    echo "<<< Creating Index Javascript file (socketio client handler) >>>"
    cat > index.js <<EOF
import './main/message'
import './styles/main.scss'
EOF
    cd main
    cat > message.js <<EOF
const io = require('socket.io-client')
const socket = io("http://localhost:5000/")

const display = document.querySelector('.messages-display')
const input = document.querySelector('.messages-input input')
const button = document.querySelector('.messages-input button')

const userHash = {}

const roomState = {
    currentMessage: "",
    receivedMEssage: ""
}

socket.on("connect", () => {

    console.log("Congratz!\nYou are connected with Socket Server!")

    socket.on("whoAmI", id => {
        userHash.id = id
    })

    input.addEventListener("change", e => {
        e.preventDefault()
        roomState.currentMessage = e.target.value
    })

    button.addEventListener("click", e => {
        e.preventDefault()
        if (roomState.currentMessage.trim() != "") {
            socket.emit("sendMessage", roomState.currentMessage)
        }
    })


    socket.on("roomData", message => {
        // creating message template:
        // Later, you should implement a better variable to 
        // handle identification!
        const parsedMessage = JSON.parse(message)
        console.debug(parsedMessage)

        const id = parsedMessage.id
        const msgContent = parsedMessage.message

        const msgContainer = document.createElement('div')
        msgContainer.classList.add('message-container')
        if (id == userHash.id) {
            msgContainer.setAttribute('sender', 'me')
        } else {
            msgContainer.setAttribute('sender', 'other')
        }

        const senderName = document.createElement('div')
        senderName.classList.add('sender-name')
        senderName.innerText = id

        const msgUnit = document.createElement('div')
        msgUnit.classList.add('message')
        msgUnit.innerText = msgContent

        msgContainer.appendChild(senderName)
        msgContainer.appendChild(msgUnit)

        display.appendChild(msgContainer)

        display.scrollTop = display.scrollHeight
    })
})
EOF
    cd ..
    cd styles
    echo "<<< Creating index.scss (main stylesheet)>>>"
    cat > main.scss <<EOF
@import url("https://fonts.googleapis.com/css2?family=Oswald:wght@200;400;500;600;700&display=swap");

:root {
    --button-width: 150px;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    height: 100vh;
    width: 100vw;
    max-width: 100%;
    background: #ffffff;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;

    font-family: "Oswald", sans-serif;
    color: #000000;
    font-size: 30px;
}

header.header {
    width: 100%;
    height: 10%;
    display: flex;
    flex-direction: row;
    justify-content: flex-start;
    align-items: center;
    background: #134b94;
    color: #ffffff;
    font-size: 0.8em;
    padding-left: 30px;
}

.messanger-container {
    height: 90%;
    width: 100vw;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}

.messanger-container .messages-display {
    height: 90%;
    width: 100%;
    padding: 30px;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: flex-end;
    overflow-y: auto;
}

.messanger-container .messages-display .message-container {
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.message-container .sender-name {
    color: #00000071;
    font-size: 0.5em;
    font-style: italic;
}

.message-container .message {
    border: none;
    border-radius: 15px;
    min-height: 50px;
    max-width: 100%;
    padding: 30px;
    font-size: 0.8em;
    color: #ffffff;
}

[sender="me"] {
    align-self: flex-start;
}

[sender="me"] .sender-name {
    align-self: flex-start;
}

[sender="me"] .message {
    background-color: #134b94;
}

[sender="other"] {
    align-self: flex-end;
}

[sender="other"] .sender-name {
    align-self: flex-end;
}

[sender="other"] .message {
    background-color: green;
}

.messanger-container .messages-input {
    margin: 0;
    padding: 5px;
    height: 10%;
    width: 100vw;
    display: flex;
    flex-direction: row;
    justify-content: flex-start;
    align-items: center;
    background-color: #00000025;
}
.messanger-container .messages-input input {
    margin: 0;
    height: 50px;
    width: calc(100vw - var(--button-width));
    font-size: 0.9em;
}

.messanger-container .messages-input button {
    margin: 0;
    width: var(--button-width);
    height: 50px;
    font-size: 0.8em;
    font-weight: 600;
}

@media (max-width: 670px) {
    header.header {
        font-size: 0.5em;
    }
    :root {
        --button-width: 100px;
    }
}
EOF

    cd ../..
    echo "<<< Creating package.json file >>>"
    cat > package.json <<EOF
{
  "name": "frontend",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "build": "webpack",
    "dev": "webpack-dev-server"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "socket.io-client": "^2.3.0"
  },
  "devDependencies": {
    "@babel/core": "^7.11.6",
    "@babel/plugin-proposal-class-properties": "^7.10.4",
    "@babel/preset-env": "^7.11.5",
    "babel-loader": "^8.1.0",
    "css-loader": "^4.3.0",
    "file-loader": "^6.1.1",
    "html-loader": "^0.5.5",
    "html-webpack-plugin": "^3.2.0",
    "mini-css-extract-plugin": "^1.0.0",
    "node-sass": "^4.14.1",
    "sass-loader": "^10.0.3",
    "style-loader": "^2.0.0",
    "webpack": "^4.29.6",
    "webpack-cli": "^3.2.3",
    "webpack-dev-server": "^3.11.0"
  }
}
EOF
    
    echo "<<< Creating webpack.config.js (builder) >>>"
    cat > webpack.config.js <<EOF
const HtmlWebPackPlugin = require("html-webpack-plugin")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")

module.exports = {
    mode: "development",
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader",
                    options: {
                        plugins: ['@babel/plugin-proposal-class-properties']
                    }
                }
            },
            {
                test: /\.html$/,
                use: [
                    {
                        loader: "html-loader",
                        options: { minimize: true }
                    }
                ]
            },
            {
                test: /\.(png|svg|jpg|gif)$/,
                use: [
                    "file-loader"
                ]
            },
            {
                test: /\.scss$/,
                use: [
                    "style-loader",
                    "css-loader",
                    "sass-loader"
                ]
            }
        ]
    },
    plugins: [
        new HtmlWebPackPlugin({
            template: "./src/index.html",
            filename: "./index.html",
            chunks: ['main']

        }),
        new MiniCssExtractPlugin({
            filename: "[name].css",
            chunkFilename: "[id].css"
        })
    ]
}
EOF
    npm install
    npm run build 
    cd ..

    echo "<<< Starting git local repository >>>"
    git init
    echo "Project $PROJECT_NAME created =)"
else
    { echo >&2 "Project alread exists, aborting now..."; exit 1; }
fi
