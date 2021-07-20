var admin = require('firebase-admin');
var serviceAccount = require('./utils/service-account.json');
const firebase = require('./utils/config');
const firestore = firebase.firestore();
const mongoose = require('mongoose');
const Token = require('../backend/model/token_model')
require('dotenv').config()

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://flutter-fire-news.firebaseio.com'
});

mongoose.connect(process.env.MONGOURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
}).then(() => console.log('Established connection to database!')).catch((e) => {
    console.log(e);
})

const getTokensFromMongodb = async () => {
    try {
        const tokensData = await Token.find({});
        const tokens = tokensData.map(t => t.token);
        console.log(tokens);
        return tokens;
    } catch (e) {
        return [];
    }
}

const getNotificationPayload = async () => {
    try {
        const querySnapshot = await firestore.collection('inshorts').orderBy('created_at', 'desc').limit(1).get();
        const notification = {
            title: querySnapshot.docs[0].data().title,
            image: querySnapshot.docs[0].data().image_url
        }
        const data = {
            category: querySnapshot.docs[0].data().category,
        }
        var payload = {
            notification: notification,
            data: data
        };
        return payload;
    } catch (e) {
        return {};
    }
}


var options = {
    priority: "high",
    timeToLive: 86400
};

const sendPush = () => {
    const hours = new Date().getHours();
    const sendNotifications = hours > 6 && hours <= 22

    console.log(hours);
    console.log(sendNotifications);

    if (sendNotifications) {
        getTokensFromMongodb().then(async (tokens) => {
            const payload = await getNotificationPayload();
            admin.messaging().sendToDevice(tokens, payload, options)
                .then(function (response) {
                    console.log("Successfully sent message:", response);
                })
                .catch(function (error) {
                    console.log("Error sending message:", error);
                });
        });
    }

}

// const getTokens = async () => {
//     try {
//         const querySnapshot = await firestore
//             .collection('tokens').get();
//         const tokens = querySnapshot.docs.map(snap => snap.data().token);
//         return tokens;
//     } catch (e) {
//         return [];
//     }
// }
// const sendPush = () => {
//     const hours = new Date().getHours();
//     const sendNotifications = hours > 6 && hours < 20

//     console.log(hours);
//     console.log(sendNotifications);

// if (sendNotifications) {
//         getTokens().then(async (tokens) => {
//             const payload = await getNotificationPayload();
//             admin.messaging().sendToDevice(tokens, payload, options)
//                 .then(function (response) {
//                     console.log("Successfully sent message:", response);
//                 })
//                 .catch(function (error) {
//                     console.log("Error sending message:", error);
//                 });
//         });
//     }

// }

module.exports = sendPush;


