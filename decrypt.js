const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Khóa KEY và IV trích xuất từ file mẫu
const KEY = Buffer.from('750bc16e58d4cd9b68ef8eb222a0bdc33f8e8f0c2d1d6e3e8ab61567434574a8', 'hex');
const IV = Buffer.from('b282c37b065ef30cc02306a6623b7abe', 'hex');

const inputFile = process.argv[2] || 'input.js';
const outputFile = process.argv[3] || 'decrypted_output.js';

try {
  const filePath = path.resolve(inputFile);
  if (!fs.existsSync(filePath)) {
    throw new Error(`Không tìm thấy file: ${inputFile}`);
  }

  const rawData = fs.readFileSync(filePath, 'utf8');

  // Trích xuất chuỗi mã hóa từ biến encrypted='...' hoặc lấy toàn bộ nếu là thuần Base64
  let cipherText = rawData.trim();
  const match = rawData.match(/encrypted\s*=\s*['"]([^'"]+)['"]/);
  if (match && match[1]) {
    cipherText = match[1];
  }

  // Tiến hành giải mã AES-256-CBC
  const decipher = crypto.createDecipheriv('aes-256-cbc', KEY, IV);
  let decrypted = decipher.update(cipherText, 'base64', 'utf8');
  decrypted += decipher.final('utf8');

  fs.writeFileSync(path.resolve(outputFile), decrypted, 'utf8');
  console.log(`✅ Giải mã thành công! Kết quả được lưu tại: ${outputFile}`);
} catch (error) {
  console.error(`❌ Lỗi trong quá trình giải mã:`, error.message);
  process.exit(1);
}
