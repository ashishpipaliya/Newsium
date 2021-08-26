const axios = require('axios');
const getNewsEndpoint = require('./utils/endpoint');
var admin = require('firebase-admin');
var serviceAccount = require('./utils/service-account.json');
const firebase = require('./utils/config');
const firestore = firebase.firestore();
const fcmpush = require('./fcmpush');
const express = require('express');
const hindi = require('./hindi')

const app = express();
const port = process.env.PORT || 5000;

app.get('/', (req, res) => {
    res.send('hello from simple server :)')
});

app.get('/categories', hindi.getCategories);

app.get('/getToken', hindi.register);

app.get('/feed/home', hindi.feed);

app.post('/category/:categoryId', hindi.byCat);

app.post('/feed/:articleId', hindi.viewArticle);

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
                        pushed_at: Date.now(),
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
        } catch (e) {
            console.log(e.message);
        }
    }
}

const deleteOldNews = async () => {
    const datediff = Date.now() - 172800000;
    const snapshot = await admin.firestore().collection('inshorts').where('pushed_at', '>=', datediff).limit(1000).get();
    snapshot.docs.map(async (doc) => {
        await doc.ref.delete();
    });
    console.log(datediff)
    console.log(`${snapshot.docs.length} news deleted`);
}

setInterval(fetchNews, 840000);
setInterval(fcmpush, 900000);
setInterval(deleteOldNews, 86400000);