var axios = require('axios');

const headers = {
    'Host': 'prod.bhaskarapi.com',
    'cities': '',
    'a-ver-name': '8.3.5',
    'a-ver-code': '457',
    'x-aut-t': 'a6oaq3edtz59',
    'cid': '521',
    'dtyp': 'android',
    'deviceid': 'f7238a09e568229f',
    'at': 'Gu3m3gVhYiR8d_iSCfG8ymQp1AtyHTPH_dEVvgtpW5LNIC8QPda1TfaudniQt5GVeEUQY-BN_VVy0sFf9SbMvXewtxlIxfpGYYyxgiRirepJrGZoUbCwtpRIAWc18QiWkCsa1xDdIanjENd8G9vsjGGwnL6ZJb_iidqlG1buhgCrVx2Ay-bclxtzHmL8bQOofZhXxSxIGH4YlahOK-oq37Ans-7j1t9tsNqZzlgYLu79ZwX10QdFogNBHp8bx15N',
    'accept-encoding': 'gzip',
    'user-agent': 'okhttp/4.6.0'
};

exports.register = async (req, res) => {
    if (req.body?.deviceId != null) {
        headers['deviceid'] = req.body?.deviceId;
    }

    var config = {
        method: 'POST',
        url: 'https://prod.bhaskarapi.com/api/1.0/user/register',
        headers: headers
    };

    axios(config)
        .then(function (response) {
            res.json({ data: response.data });
        })
        .catch(function (error) {
            res.status(400).json({
                message: error.message
            })
        });
}

exports.getCategories = async (req, res) => {

    if (req.body != null) {
        headers['deviceid'] = req.body?.deviceId;
        headers['at'] = req.body?.at;
    }

    var config = {
        method: 'get',
        url: 'https://prod.bhaskarapi.com/api/2.0/lists/cats',
        headers: headers
    };

    axios(config)
        .then(function (response) {
            res.json({ data: response.data.cats });
        })
        .catch(function (error) {
            res.status(400).json({
                message: error.message
            })
        });
}

exports.feed = async (req, res) => {

    if (req.body != null) {
        headers['deviceid'] = req.body?.deviceId;
        headers['at'] = req.body?.at;
    }

    var config = {
        method: 'get',
        url: `https://prod.bhaskarapi.com/api/2.0/feed/home`,
        headers: headers
    };
    axios(config)
        .then(function (response) {
            res.json({ data: response.data.feed });
        })
        .catch(function (error) {
            res.status(400).json({
                message: error.message
            })
        });
}

exports.byCat = async (req, res) => {
    const categoryId = req.params?.categoryId;

    if (req.body != null) {
        headers['deviceid'] = req.body?.deviceId;
        headers['at'] = req.body?.at;
    }

    var config = {
        method: 'get',
        url: `https://prod.bhaskarapi.com/api/2.0/feed/category/${categoryId}`,
        headers: headers
    };

    axios(config)
        .then(function (response) {
            res.json({
                data: response.data.feed
            })
        })
        .catch(function (error) {
            res.status(400).json({
                message: error.message
            })
        });
}


exports.viewArticle = async (req, res) => {
    var articleId;

    if (req.body != null) {
        headers['deviceid'] = req.body?.deviceId;
        headers['at'] = req.body?.at;
        articleId = req.body?.storyId;
    }

    console.log(headers.deviceid);

    var config = {
        method: 'get',
        url: `https://prod.bhaskarapi.com/api/1.0/feed/story/${articleId}`,
        headers: headers
    };


    console.log(headers);

    axios(config)
        .then(function (response) {
            res.json({ data: response.data });
        })
        .catch(function (error) {
            res.status(400).json({
                message: error.message
            })
        });
}