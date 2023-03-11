#!/bin/sh

echo "Defining variables ..."

USERNAME='your_virtualmachine_username'
EMAIL='your_company_email_address'
PASSWORD='your_company_password'
COMPANY='your_company_name'

echo "Scheduling Monet ..."

su - $USERNAME -c "echo '59 7 * * 1-5 /usr/local/bin/node /home/$USERNAME/monet-automation/1available.js >> /home/$USERNAME/monet-automation/logs/cron.log 2>&1' >> cron.jobs"
su - $USERNAME -c "echo '59 9 * * 1-5 /usr/local/bin/node /home/$USERNAME/monet-automation/2break.js >> /home/$USERNAME/monet-automation/logs/cron.log 2>&1' >> cron.jobs"
su - $USERNAME -c "echo '29 10 * * 1-5 /usr/local/bin/node /home/$USERNAME/monet-automation/1available.js >> /home/$USERNAME/monet-automation/logs/cron.log 2>&1' >> cron.jobs"
su - $USERNAME -c "echo '59 12 * * 1-5 /usr/local/bin/node /home/$USERNAME/monet-automation/3lunch.js >> /home/$USERNAME/monet-automation/logs/cron.log 2>&1' >> cron.jobs"
su - $USERNAME -c "echo '59 13 * * 1-5 /usr/local/bin/node /home/$USERNAME/monet-automation/1available.js >> /home/$USERNAME/monet-automation/logs/cron.log 2>&1' >> cron.jobs"
su - $USERNAME -c "echo '59 16 * * 1-5 /usr/local/bin/node /home/$USERNAME/monet-automation/4endofshift.js >> /home/$USERNAME/monet-automation/logs/cron.log 2>&1' >> cron.jobs"

su - $USERNAME -c 'crontab cron.jobs'
su - $USERNAME -c 'rm cron.jobs'

timedatectl set-timezone America/Costa_Rica

systemctl restart cron.service

echo "Updating and installing packages ..."

apt update
apt upgrade -y
apt install libatk1.0-0 libatk-bridge2.0-0 libcups2 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libxkbcommon0 libpango1.0-0 libcairo2 -y

echo "Installing NodeJS ..."

wget https://nodejs.org/dist/v18.14.2/node-v18.14.2-linux-x64.tar.xz
tar -xf node-v18.14.2-linux-x64.tar.xz
rm node-v18.14.2-linux-x64.tar.xz
cd node-v18.14.2-linux-x64/
cp -R * /usr/local/
rm -rf node-v18.14.2-linux-x64

echo "Preparing the scripts for Monet Automation ..."

if [ ! -d /home/$USERNAME/monet-automation ]; then
  mkdir /home/$USERNAME/monet-automation
  mkdir /home/$USERNAME/monet-automation/logs
  touch /home/$USERNAME/monet-automation/logs/cron.log
fi
cd /home/$USERNAME/monet-automation
npm init -y
npm install puppeteer

cat > /home/$USERNAME/monet-automation/credentials.js <<EOF
// Your credentials

const company = '$COMPANY';
const email = '$EMAIL';
const password = '$PASSWORD';

module.exports = {
  company,
  email,
  password,
};
EOF

cat > /home/$USERNAME/monet-automation/1available.js <<EOF
const puppeteer = require('puppeteer');

(async () => {
  const credentials = require('./credentials');
  const browser = await puppeteer.launch({ 
  headless: true
  });
  
  const page = await browser.newPage();
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36');

  // Navigate to the website and wait for the company name input field to load
  await page.goto('https://www.monetwfo-eu.com');
  await page.waitForSelector('#txtTenantId');

  // Enter the company name and click the "Next" button
  await page.type('#txtTenantId', credentials.company);
  await page.type('#txtUserName', credentials.email);
  await page.type('#txtPassword', credentials.password);
  await page.click('#btnSubmit');

  // Wait for the Microsoft login page to load
  await page.waitForSelector('#i0116');

  // Enter your Microsoft account email address and click the "Next" button
  await page.type('#i0116', credentials.email);
  await page.click('#idSIButton9');

  // Wait for the password field to load
  await page.waitForSelector('#i0118');

  // Enter your Microsoft account password and click the "Sign in" button
  await page.type('#i0118', credentials.password);
  await page.waitForTimeout(1000); // Wait for 1 second
  await page.click('#idSIButton9');

  // Press "Yes" to stay signed in but it doesn't matter as it will be asked everytime
  await page.waitForSelector('#idSIButton9');
  await page.waitForTimeout(1000); // Wait for 1 second
  await page.click('#idSIButton9');
  
  try {
    // Wait for the password field to load
    await page.waitForSelector('#submitmanualStatusChange', { timeout: 120000});

    // Select the value "01. Available/Case Work" from the drop-down menu
    await page.click('#statusListCombo');
    await page.waitForSelector('#statusListCombo option[value="01. Available/Case Work"]');
    await page.evaluate(() => {
      const option = document.querySelector('#statusListCombo option[value="01. Available/Case Work"]');
      option.selected = true;
      option.dispatchEvent(new Event('change', { bubbles: true }));
    });

    // Click the "Submit" button
    await page.waitForTimeout(1000); // Wait for 1 second
    await page.click('#submitmanualStatusChange');
    await page.waitForTimeout(10000); // Wait for 10 second
  } catch (error) {
    // If the selector times out, take a screenshot and log the error
    console.error('Error:', error);
    await page.screenshot({ path: 'screenshot.png' });
  }
// Close the browser
await browser.close();
})();
EOF

cat > /home/$USERNAME/monet-automation/2break.js <<EOF
const puppeteer = require('puppeteer');

(async () => {
  const credentials = require('./credentials');
  const browser = await puppeteer.launch({ 
  headless: true
  });
  
  const page = await browser.newPage();
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36');

  // Navigate to the website and wait for the company name input field to load
  await page.goto('https://www.monetwfo-eu.com');
  await page.waitForSelector('#txtTenantId');

  // Enter the company name and click the "Next" button
  await page.type('#txtTenantId', credentials.company);
  await page.type('#txtUserName', credentials.email);
  await page.type('#txtPassword', credentials.password);
  await page.click('#btnSubmit');

  // Wait for the Microsoft login page to load
  await page.waitForSelector('#i0116');

  // Enter your Microsoft account email address and click the "Next" button
  await page.type('#i0116', credentials.email);
  await page.click('#idSIButton9');

  // Wait for the password field to load
  await page.waitForSelector('#i0118');

  // Enter your Microsoft account password and click the "Sign in" button
  await page.type('#i0118', credentials.password);
  await page.waitForTimeout(1000); // Wait for 1 second
  await page.click('#idSIButton9');

  // Press "Yes" to stay signed in but it doesn't matter as it will be asked everytime
  await page.waitForSelector('#idSIButton9');
  await page.waitForTimeout(1000); // Wait for 1 second
  await page.click('#idSIButton9');
  
  try {
    // Wait for the password field to load
    await page.waitForSelector('#submitmanualStatusChange', { timeout: 120000});

    // Select the value "01. Available/Case Work" from the drop-down menu
    await page.click('#statusListCombo');
    await page.waitForSelector('#statusListCombo option[value="01. Available/Case Work"]');
    await page.evaluate(() => {
      const option = document.querySelector('#statusListCombo option[value="01. Available/Case Work"]');
      option.selected = true;
      option.dispatchEvent(new Event('change', { bubbles: true }));
    });

    // Click the "Submit" button
    await page.waitForTimeout(1000); // Wait for 1 second
    await page.click('#submitmanualStatusChange');
    await page.waitForTimeout(10000); // Wait for 10 second
  } catch (error) {
    // If the selector times out, take a screenshot and log the error
    console.error('Error:', error);
    await page.screenshot({ path: 'screenshot.png' });
  }
// Close the browser
await browser.close();
})();
EOF

cat > /home/$USERNAME/monet-automation/3lunch.js <<EOF
const puppeteer = require('puppeteer');

(async () => {
  const credentials = require('./credentials');
  const browser = await puppeteer.launch({ 
  headless: true
  });
  
  const page = await browser.newPage();
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36');

  // Navigate to the website and wait for the company name input field to load
  await page.goto('https://www.monetwfo-eu.com');
  await page.waitForSelector('#txtTenantId');

  // Enter the company name and click the "Next" button
  await page.type('#txtTenantId', credentials.company);
  await page.type('#txtUserName', credentials.email);
  await page.type('#txtPassword', credentials.password);
  await page.click('#btnSubmit');

  // Wait for the Microsoft login page to load
  await page.waitForSelector('#i0116');

  // Enter your Microsoft account email address and click the "Next" button
  await page.type('#i0116', credentials.email);
  await page.click('#idSIButton9');

  // Wait for the password field to load
  await page.waitForSelector('#i0118');

  // Enter your Microsoft account password and click the "Sign in" button
  await page.type('#i0118', credentials.password);
  await page.waitForTimeout(1000); // Wait for 1 second
  await page.click('#idSIButton9');

  // Press "Yes" to stay signed in but it doesn't matter as it will be asked everytime
  await page.waitForSelector('#idSIButton9');
  await page.waitForTimeout(1000); // Wait for 1 second
  await page.click('#idSIButton9');
  
  try {
    // Wait for the password field to load
    await page.waitForSelector('#submitmanualStatusChange', { timeout: 120000});

    // Select the value "01. Available/Case Work" from the drop-down menu
    await page.click('#statusListCombo');
    await page.waitForSelector('#statusListCombo option[value="01. Available/Case Work"]');
    await page.evaluate(() => {
      const option = document.querySelector('#statusListCombo option[value="01. Available/Case Work"]');
      option.selected = true;
      option.dispatchEvent(new Event('change', { bubbles: true }));
    });

    // Click the "Submit" button
    await page.waitForTimeout(1000); // Wait for 1 second
    await page.click('#submitmanualStatusChange');
    await page.waitForTimeout(10000); // Wait for 10 second
  } catch (error) {
    // If the selector times out, take a screenshot and log the error
    console.error('Error:', error);
    await page.screenshot({ path: 'screenshot.png' });
  }
// Close the browser
await browser.close();
})();
EOF

cat > /home/$USERNAME/monet-automation/4endofshift.js <<EOF
const puppeteer = require('puppeteer');

(async () => {
  const credentials = require('./credentials');
  const browser = await puppeteer.launch({ 
  headless: true
  });
  
  const page = await browser.newPage();
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36');

  // Navigate to the website and wait for the company name input field to load
  await page.goto('https://www.monetwfo-eu.com');
  await page.waitForSelector('#txtTenantId');

  // Enter the company name and click the "Next" button
  await page.type('#txtTenantId', credentials.company);
  await page.type('#txtUserName', credentials.email);
  await page.type('#txtPassword', credentials.password);
  await page.click('#btnSubmit');

  // Wait for the Microsoft login page to load
  await page.waitForSelector('#i0116');

  // Enter your Microsoft account email address and click the "Next" button
  await page.type('#i0116', credentials.email);
  await page.click('#idSIButton9');

  // Wait for the password field to load
  await page.waitForSelector('#i0118');

  // Enter your Microsoft account password and click the "Sign in" button
  await page.type('#i0118', credentials.password);
  await page.waitForTimeout(1000); // Wait for 1 second
  await page.click('#idSIButton9');

  // Press "Yes" to stay signed in but it doesn't matter as it will be asked everytime
  await page.waitForSelector('#idSIButton9');
  await page.waitForTimeout(1000); // Wait for 1 second
  await page.click('#idSIButton9');
  
  try {
    // Wait for the password field to load
    await page.waitForSelector('#submitmanualStatusChange', { timeout: 120000});

    // Select the value "01. Available/Case Work" from the drop-down menu
    await page.click('#statusListCombo');
    await page.waitForSelector('#statusListCombo option[value="01. Available/Case Work"]');
    await page.evaluate(() => {
      const option = document.querySelector('#statusListCombo option[value="01. Available/Case Work"]');
      option.selected = true;
      option.dispatchEvent(new Event('change', { bubbles: true }));
    });

    // Click the "Submit" button
    await page.waitForTimeout(1000); // Wait for 1 second
    await page.click('#submitmanualStatusChange');
    await page.waitForTimeout(10000); // Wait for 10 second
  } catch (error) {
    // If the selector times out, take a screenshot and log the error
    console.error('Error:', error);
    await page.screenshot({ path: 'screenshot.png' });
  }
// Close the browser
await browser.close();
})();
EOF

chown -R $USERNAME:$USERNAME /home/$USERNAME/monet-automation
chmod -R 755 /home/$USERNAME/monet-automation
mv /root/.cache /home/$USERNAME/
chown -R $USERNAME:$USERNAME /home/$USERNAME/.cache
chmod -R 755 /home/$USERNAME/.cache