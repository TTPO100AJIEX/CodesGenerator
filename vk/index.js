import WebSocket from 'ws';

const res = await fetch("https://api.vk.com/method/groups.getLongPollServer?v=5.199&group_id=192568540", {
    method: "POST",
    headers: {
        "Authorization": "Bearer ttt"
    }
});
console.log(await res.json())
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