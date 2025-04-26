#!/bin/bash

# Test different system sounds
echo "Testing system sounds..."

# Function to play a sound
play_sound() {
    local sound=$1
    echo "Playing $sound..."
    afplay "/System/Library/Sounds/$sound.aiff"
    sleep 1
}

# Play each sound three times
for i in {1..3}; do
    echo "Round $i:"
    play_sound "Bottle"
    play_sound "Bottle"
    play_sound "Bottle"
    echo ""
    
    play_sound "Funk"
    play_sound "Funk"
    play_sound "Funk"
    echo ""
    
    play_sound "Glass"
    play_sound "Glass"
    play_sound "Glass"
    echo ""
done

echo "Sound test complete!" 