var express = require('express');
var router = express.Router();
var crypto = require('crypto');

router.get('/', function(req, res, next) {
	var timestamp = new Date().toString();
	var md5 = crypto.createHash('md5');
	var key = md5.update(timestamp).digest('hex');

  	res.render('index', { key: key });
});

module.exports = router;
