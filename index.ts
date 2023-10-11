import * as core from '@actions/core';

async function run() {
    try {
        // Your action logic goes here

        core.setOutput('result', 'Hello from your TypeScript GitHub Action!');
    } catch (error) {
        core.setFailed(error.message);
    }
}

run();