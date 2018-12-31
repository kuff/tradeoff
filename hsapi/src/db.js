const animals = require('../animals.json');
const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const shortid = require('shortid');

module.exports = class DatabaseHandler {

    constructor(file) {
        this.db = low(new FileSync(file));
        this.db.defaults({ highscores: new Map() });
    }

    generateAnimal(id) {
        // generate a new unique animal identifier
        const preexisting_animal = this.getPlayer(id);
        let name;
        if (!preexisting_animal) {
            const used_animals = this.db.get('highscores').values()
                .map(elem => elem.name).value();
            let unused_animals
            if (used_animals.length > 0) 
                unused_animals = animals.filter(animal => 
                    used_animals.indexOf(animal) == -1);
            name = unused_animals && unused_animals[Math.round(Math.random()
                * (unused_animals.length - 1))]
                || animals[Math.round(Math.random()
                * (animals.length - 1))];
        }
        // save this new identifier to the db and return it
        this.db.set(`highscores[${id}]`, {
            name: name || preexisting_animal.name,
            secret: shortid.generate(),
            score: preexisting_animal && preexisting_animal.score
        }).value();
        this.db.write();
        return name || preexisting_animal.name;
    }

    getPlayer(id) {
        return this.db.get(`highscores[${id}]`).value();
    }

    getScoreboard() {
        let map = new Map();
        this.db.get('highscores').values().forEach(elem =>
            map.set(elem.name, elem.score || 0))
            .value();
        let sorted_sequence = [];
        map.forEach((v, k) => 
            sorted_sequence.push({
                name: k,
                score: v
            }));
        sorted_sequence.sort((a, b) => b.score - a.score);
        return sorted_sequence;
    }

    verify(secret) {
        const found = this.db.get('highscores')
            .find(elem => elem.secret == secret).value();
        return found != undefined;
    }

    postScore(id, score) {
        // start by checking if the score should go on the board
        const player = this.getPlayer(id);
        if (score > (player.score || 0)) {
            this.db.set(`highscores[${id}].score`, score).value();
            this.db.write();
        }
    }

}