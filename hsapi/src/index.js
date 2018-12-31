const { game_name } = require('../settings.json');
const DatabaseHandler = require('./db.js');
const express = require('express');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');

const app = express();
app.use(helmet());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(cookieParser());

const db = new DatabaseHandler('db.json');

app.get(`/${game_name}/register`, (req, res) => {

    // start by checking if the user already exists
    const id = req.ip.toString().replace(/\./g, 'd');
    const player = db.getPlayer(id);
    const name = db.generateAnimal(id)
    if (!name) return res.send({
        success: false,
        reason: "No more space on the leaderboard!"
    })
    // formulate the response object, saving the requester's ip
    const response = {
        success: true,
        already_registered: player != undefined,
        name: name
    }
    // send the response object along with a session cookie
    res.cookie(`${game_name}_${db.getPlayer(id).name}`, 
        db.getPlayer(id).secret);
    res.send(response);

})

app.get(`/${game_name}/scoreboard`, (req, res) => {

    // respond with the a scorebord object without ids
    res.send({
        success: true,
        data: db.getScoreboard()
    });

});

app.get(`/${game_name}/postscore`, (req, res) => {

    console.log(req.headers);
    // save the score
    const score = parseInt(req.query.s);
    const id = req.ip.toString().replace(/\./g, 'd');
    const player = db.getPlayer(id);
    let secret = req.cookies[`${game_name}_${player.name}`];
    if (db.verify(secret)) db.postScore(id, score);
    res.send({
        success: db.verify(secret),
        highscore: player.score
    });

});

app.listen(80, () => console.log("Listening to port 80!"));