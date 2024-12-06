const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const fs = require('fs');
const path = require('path');


const app = express();


app.use(bodyParser.json());
app.use(cors());

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });


const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'auth_db',
});

db.connect((err) => {
    if (err) {
        console.error('Kết nối MySQL thất bại:', err);
        return;
    }
    console.log('Kết nối MySQL thành công!');
});


app.get('', (req, res) => {
    res.send('Xin chào! Chào mừng bạn đến với API của tôi!');
});


app.get('/users', (req, res) => {
    const sql = 'SELECT usrId, email, usrName, usrPassword, image FROM users';
    db.query(sql, (err, result) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json(result);
        }
    });
});


app.get('/users/:id', (req, res) => {
    const userId = req.params.id;


    const sql = 'SELECT usrId, usrName, email, image FROM users WHERE usrId = ?';
    db.query(sql, [userId], (err, result) => {
        if (err) {
            return res.status(500).send({ error: 'Lỗi server' });
        }

        if (result.length > 0) {
            const user = result[0];

            res.json({
                usrId: user.usrId,
                usrName: user.usrName,
                email: user.email,
                image: user.image,
            });
        } else {
            res.status(404).send({ message: 'Không tìm thấy người dùng!' });
        }
    });
});





app.post('/register', upload.single('image'), (req, res) => {
    const { usrName, email, usrPassword, image } = req.body;
console.log(req.body)

  if (!usrName) {
    return res.status(400).json({ success: false, message: 'Thiếu tên người dùng.' });
  }

  if (!email) {
    return res.status(400).json({ success: false, message: 'Thiếu email.' });
  }

  if (!usrPassword) {
    return res.status(400).json({ success: false, message: 'Thiếu mật khẩu.' });
  }

  if (!image) {
    return res.status(400).json({ success: false, message: 'Thiếu ảnh.' });
  }

    const imageBase64 = image;

    const checkQuery = `SELECT * FROM users WHERE email = ? OR usrName = ?`;
    db.query(checkQuery, [email, usrName], (err, results) => {
        if (err) {
            return res.status(500).json({ success: false, message: 'Lỗi server.' });
        }

        if (results.length > 0) {
            return res.status(400).json({ success: false, message: 'Email hoặc tên người dùng đã tồn tại.' });
        }

        const insertQuery = `INSERT INTO users (usrName, email, usrPassword, image) VALUES (?, ?, ?, ?)`;
        db.query(insertQuery, [usrName, email, usrPassword, imageBase64], (err, result) => {
            if (err) {
                return res.status(500).json({ success: false, message: 'Lỗi server.' });
            }

            res.json({ success: true, message: 'Đăng ký thành công.' });
        });
    });
});


app.post('/login', (req, res) => {
    const { usrName, usrPassword } = req.body;
    const sql = `SELECT * FROM users WHERE usrName = ? AND usrPassword = ?`;
    db.query(sql, [usrName, usrPassword], (err, result) => {
        if (err) {
            res.status(500).send({ error: 'Lỗi server' });
        } else if (result.length > 0) {
            res.send({ success: true, message: 'Đăng nhập thành công!', user: result[0] });
        } else {
            res.status(401).send({ success: false, message: 'Tên đăng nhập hoặc mật khẩu không đúng.' });
        }
    });
});

app.put('/users/:id', (req, res) => {
    const userId = req.params.id;
    const { email, usrName, image } = req.body;
    const sql = `
        UPDATE users
        SET email = ?, usrName = ?, image = ?
        WHERE usrId = ?
    `;


    db.query(sql, [email, usrName, image, userId], (err, result) => {
        if (err) {
            res.status(500).send(err);
        } else if (result.affectedRows === 0) {
            res.status(404).send({ message: 'Người dùng không tồn tại!' });
        } else {
            res.send({ message: 'Cập nhật người dùng thành công!' });
        }
    });
});


app.delete('/users/:id', (req, res) => {
    const userId = req.params.id;
    const sql = 'DELETE FROM users WHERE usrId = ?';
    db.query(sql, [userId], (err, result) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.send({ message: 'Xóa người dùng thành công!' });
        }
    });
});


const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server chạy tại http://localhost:${PORT}`);
});
