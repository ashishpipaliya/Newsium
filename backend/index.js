const axios = require('axios');
const getNewsEndpoint = require('./utils/endpoint');
const firebase = require('./utils/config');
const firestore = firebase.firestore();
const fcmpush = require('./fcmpush');
const express = require('express');

const app = express();
const port = process.env.PORT || 3000;


app.get('/', (req, res) => {
    res.send('hello from simple server :)')
});

app.listen(port, ()=>{
    console.log('server running on ' + port);
});


const fetchNews = async () => {
    const categories = [
        'all_news', 'trending', 'top_stories', 'national', 'business', 'politics', 'sports', 'technology', 'startups', 'entertainment', 'hatke', 'education', 'world', 'automobile', 'science', 'travel', 'miscellaneous', 'fashion'];

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

const addNews = async (data) => {
    if (data != null) {
        try {
            const result = await firestore.collection('inshorts').doc(data.hash_id).get();
            if (!result.exists) {
                await firestore.collection('inshorts').doc(data.hash_id).set(data, { merge: false });
                console.log('added');
            } else {
                console.log('news already exists');
            }
        } catch (e) {
            console.log(e.message);
        }
    }
}

const deleteOldNews = async () => {
    const datediff = Date.now() - 172800000;
    const snapshot = await firestore.collection('inshorts').where('created_at', '<=', datediff).get();
    snapshot.docs.map(async (doc) => {
        await doc.ref.delete();
    });
    console.log(`${snapshot.docs.length} news deleted`);
}

setInterval(fetchNews, 150000);
setInterval(fcmpush, 1800000);
setInterval(deleteOldNews, 86400000);