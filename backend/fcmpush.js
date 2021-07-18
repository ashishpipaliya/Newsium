var admin = require('firebase-admin');
var serviceAccount = require('./utils/service-account.json');
const firebase = require('./utils/config');
const firestore = firebase.firestore();

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://flutter-fire-news.firebaseio.com'
});

const getTokens = async () => {
    try {
        const querySnapshot = await firestore
            .collection('tokens').get();
        const tokens = querySnapshot.docs.map(snap => snap.data().token);
        return tokens;
    } catch (e) {
        return [];
    }
}

const getNotificationPayload = async (category) => {
    try {
        const querySnapshot = await firestore.collection('inshorts').where('category', '==', category).orderBy('created_at', 'desc').limit(1).get();
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
        return [];
    }
}



var options = {
    priority: "high",
    timeToLive: 86400
};

const sendPush = (category) => {
    getTokens().then(async (tokens) => {
        const payload = await getNotificationPayload(category);
        admin.messaging().sendToDevice(tokens, payload, options)
            .then(function (response) {
                console.log("Successfully sent message:", response);
            })
            .catch(function (error) {
                console.log("Error sending message:", error);
            });
    });
}

module.exports = sendPush;


