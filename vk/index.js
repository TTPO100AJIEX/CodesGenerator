import WebSocket from 'ws';

const res = await fetch("https://api.vk.com/method/streaming.getServerUrl?v=5.199", {
    headers: {
        "Authorization": "Bearer a3bff939a3bff939a3bff939dca3cb98e4aa3bfa3bff939fc3a77940d0f425061c77fce"
    }
});
const { response } = await res.json();


const socket = new WebSocket(`wss://${response.endpoint}/stream?key=${response.key}`);

socket.on('open', data =>
{
    console.log('open')
});
socket.on('message', data =>
{
    console.log(data)
});
socket.on('close', data =>
{
    console.log('close')
});
socket.on('error', data =>
{
    console.log('error')
});