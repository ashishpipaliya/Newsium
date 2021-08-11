const axios = require('axios');
const getNewsEndpoint = require('./utils/endpoint');
var admin = require('firebase-admin');
var serviceAccount = require('./utils/service-account.json');
const firebase = require('./utils/config');
const firestore = firebase.firestore();
const fcmpush = require('./fcmpush');
const express = require('express');

const app = express();
const port = process.env.PORT || 5000;

// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount),
//     databaseURL: 'https://flutter-fire-news.firebaseio.com'
// });


app.get('/', (req, res) => {
    res.send('hello from simple server :)')
});

app.listen(port, () => {
    console.log('server running on ' + port);
});


const fetchNews = async () => {
    const categories = [
        'trending', 'top_stories', 'national', 'business', 'politics', 'sports', 'technology', 'startups', 'entertainment', 'hatke', 'education', 'world', 'automobile', 'science', 'travel', 'miscellaneous', 'fashion'];

    const hours = new Date().getHours();
    const fetchNews = hours >= 6 && hours <= 22
    console.log(`fetch news = ${fetchNews}`);

    if (fetchNews) {
        categories.forEach(async (category) => {
            let response = await axios
                .get(getNewsEndpoint(category))
                .catch((err) => {
                    console.log(err);
                });

            response.data.data.news_list.forEach(async (article) => {
                const newsObj = article['news_obj'];

                if ((Date.now() - article.news_obj.created_at) < 86400000) {
                    const singleNewsData = {
                        category: category,
                        hash_id: article['hash_id'],
                        title: newsObj['title'],
                        description: newsObj['content'],
                        author_name: newsObj['author_name'],
                        source_name: newsObj['source_name'],
                        source_url: newsObj['source_url'],
                        image_url: newsObj['image_url'],
                        created_at: newsObj['created_at'],
                        inshorts_url: newsObj['shortened_url'],
                    };
                    await addNews(singleNewsData)
                }

            });
        });
    }


}

const addNews = async (data) => {
    if (data != null) {
        try {

            await admin.firestore().collection('inshorts').doc(data.hash_id).set(data, { merge: true });
            // console.log(`${data.title} added`);

        } catch (e) {
            console.log(e.message);
        }
    }
}

const deleteOldNews = async () => {
    const datediff = Date.now() - 172800000;
    const snapshot = await admin.firestore().collection('inshorts').where('created_at', '<=', datediff).get();
    snapshot.docs.map(async (doc) => {
        await doc.ref.delete();
    });
    console.log(`${snapshot.docs.length} news deleted`);
}

setInterval(fetchNews, 840000);
setInterval(fcmpush, 900000);
setInterval(deleteOldNews, 86400000);