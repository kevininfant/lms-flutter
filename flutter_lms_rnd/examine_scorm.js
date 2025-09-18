#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

/**
 * Simple utility to examine SCORM ZIP files
 * Usage: node examine_scorm.js <path-to-scorm.zip>
 */

function examineScormZip(zipPath) {
    console.log(`\n🔍 Examining SCORM package: ${zipPath}\n`);
    
    if (!fs.existsSync(zipPath)) {
        console.error(`❌ File not found: ${zipPath}`);
        return;
    }
    
    try {
        // Create temporary extraction directory
        const tempDir = path.join(__dirname, 'temp_scorm_extract');
        if (fs.existsSync(tempDir)) {
            fs.rmSync(tempDir, { recursive: true, force: true });
        }
        fs.mkdirSync(tempDir, { recursive: true });
        
        // Extract the ZIP file
        console.log('📦 Extracting SCORM package...');
        execSync(`unzip -q "${zipPath}" -d "${tempDir}"`, { stdio: 'pipe' });
        
        // List contents
        console.log('\n📁 SCORM Package Contents:');
        console.log('=' .repeat(50));
        listDirectoryContents(tempDir, '');
        
        // Look for manifest
        console.log('\n📋 Looking for SCORM manifest...');
        const manifestPath = findManifest(tempDir);
        if (manifestPath) {
            console.log(`✅ Found manifest: ${manifestPath}`);
            examineManifest(manifestPath);
        } else {
            console.log('❌ No manifest found');
        }
        
        // Look for HTML files
        console.log('\n🌐 Looking for HTML launch files...');
        const htmlFiles = findHtmlFiles(tempDir);
        if (htmlFiles.length > 0) {
            console.log('✅ Found HTML files:');
            htmlFiles.forEach(file => console.log(`   - ${file}`));
        } else {
            console.log('❌ No HTML files found');
        }
        
        // Cleanup
        fs.rmSync(tempDir, { recursive: true, force: true });
        console.log('\n✨ Analysis complete!');
        
    } catch (error) {
        console.error(`❌ Error examining SCORM package: ${error.message}`);
    }
}

function listDirectoryContents(dir, prefix) {
    const items = fs.readdirSync(dir, { withFileTypes: true });
    items.forEach(item => {
        const itemPath = path.join(dir, item.name);
        const displayPath = prefix + item.name;
        
        if (item.isDirectory()) {
            console.log(`📁 ${displayPath}/`);
            listDirectoryContents(itemPath, prefix + '  ');
        } else {
            const stats = fs.statSync(itemPath);
            const size = formatFileSize(stats.size);
            console.log(`📄 ${displayPath} (${size})`);
        }
    });
}

function findManifest(dir) {
    const items = fs.readdirSync(dir, { withFileTypes: true });
    
    for (const item of items) {
        const itemPath = path.join(dir, item.name);
        
        if (item.isDirectory()) {
            const found = findManifest(itemPath);
            if (found) return found;
        } else if (item.name.toLowerCase() === 'imsmanifest.xml') {
            return itemPath;
        }
    }
    
    return null;
}

function findHtmlFiles(dir) {
    const htmlFiles = [];
    const items = fs.readdirSync(dir, { withFileTypes: true });
    
    for (const item of items) {
        const itemPath = path.join(dir, item.name);
        
        if (item.isDirectory()) {
            htmlFiles.push(...findHtmlFiles(itemPath));
        } else if (path.extname(item.name).toLowerCase() === '.html') {
            htmlFiles.push(itemPath);
        }
    }
    
    return htmlFiles;
}

function examineManifest(manifestPath) {
    try {
        const content = fs.readFileSync(manifestPath, 'utf8');
        console.log('\n📄 Manifest Content Preview:');
        console.log('-'.repeat(30));
        
        // Extract key information
        const titleMatch = content.match(/<title[^>]*>([^<]+)<\/title>/i);
        if (titleMatch) {
            console.log(`Title: ${titleMatch[1]}`);
        }
        
        const orgMatch = content.match(/<organization[^>]*identifier="([^"]+)"/i);
        if (orgMatch) {
            console.log(`Organization: ${orgMatch[1]}`);
        }
        
        const resourceMatches = content.match(/<resource[^>]*href="([^"]+)"[^>]*>/gi);
        if (resourceMatches) {
            console.log('\nResources:');
            resourceMatches.forEach(match => {
                const hrefMatch = match.match(/href="([^"]+)"/i);
                if (hrefMatch) {
                    console.log(`  - ${hrefMatch[1]}`);
                }
            });
        }
        
    } catch (error) {
        console.log(`❌ Error reading manifest: ${error.message}`);
    }
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Main execution
const zipPath = process.argv[2];
if (!zipPath) {
    console.log('Usage: node examine_scorm.js <path-to-scorm.zip>');
    console.log('\nExamples:');
    console.log('  node examine_scorm.js assets/data/scorm.zip');
    console.log('  node examine_scorm.js assets/data/pri.zip');
    process.exit(1);
}

examineScormZip(zipPath);
