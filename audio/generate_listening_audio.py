#!/usr/bin/env python3
"""
Generate 24 MP3 audio files using Microsoft Edge TTS (edge-tts).
No API key, no account, no AWS. Completely free.

Install:
    pip install edge-tts

Usage:
    python3 generate_listening_audio.py
"""

import asyncio
import edge_tts
from pathlib import Path

# Output directory
OUTPUT_DIR = Path("./generated_audio")
OUTPUT_DIR.mkdir(exist_ok=True)

# Scripts — copy from the HTML page
SCRIPTS = {
    # G6 Mock (Male/Female alternate)
    "g6m1": "Welcome to our school talent show. Today we have three amazing performers. First, Maria will play the piano. She has practised for two months. Next, Tom and Jerry will do a comedy sketch. They are very funny. Finally, our choir will sing a song about friendship. Please welcome them with a big round of applause!",
    "g6m2": "Hello and welcome to the Summer Fitness Challenge. I am your coach, Mike. This week we will run, swim, and cycle every day. On Monday, we start with a two-kilometre run in the park. On Wednesday, we swim twenty lengths at the pool. And on Friday, we cycle around the lake. Remember to drink water and stretch before every workout. Let's get fit together!",
    "g6m3": "Welcome to Jungle Survival! You are on a tropical island with only basic tools. Your challenge today: build a shelter before sunset. You have bamboo, rope, and leaves. Work in teams of four. The judges will check your shelter at six o'clock. The winning team gets a special prize. Good luck, survivors!",
    "g6m4": "Good evening, everyone, and welcome to the Big Brain Quiz Show! I am your host, Lisa. Tonight, four brave students will answer questions about science, history, and geography. Contestants, are you ready? Let's start with round one: Science! Question one — what is the chemical symbol for water? Is it A) CO2, B) H2O, or C) O2? You have ten seconds!",
    
    # G6 Final
    "g6f1": "When I grow up, I want to be a pilot. I love watching planes take off at the airport. My uncle is a pilot, and he travels to many countries. He says the job is exciting but you must study hard. I am good at maths and geography, so I think I can do it. One day, I hope to fly a big Boeing 747 across the ocean.",
    "g6f2": "Our school has a new uniform rule. From next term, all students must wear a white shirt, blue trousers, and black shoes. The head teacher says it will help us look smart. Some students do not like it because the uniform is expensive. But I think it is good because we will not worry about clothes every morning. Also, everyone will look the same, so nobody will feel different.",
    "g6f3": "Eating healthy food is very important. Every day, I have fruit for breakfast, rice and vegetables for lunch, and fish with salad for dinner. My mother says too much sugar is bad for my teeth, so I only eat chocolate on Saturdays. I also drink a lot of water and never have fizzy drinks. Since I started eating well, I have more energy and I sleep better at night.",
    "g6f4": "This weekend, my family and I are going to the countryside. We will leave on Saturday morning and stay in a small cottage near a lake. On Saturday afternoon, we will go hiking in the forest. On Sunday, my father will teach me how to fish. My mother will make a picnic lunch. I am very excited because I have never been fishing before. I hope the weather is sunny!",
    
    # G7 Mock
    "g7m1": "Good morning, everyone. I am Dr. Chen from TechFuture Company. Today, I will introduce our new robot assistant, model name 'Helpy'. Helpy can clean your house, cook simple meals, and even remind you to take medicine. It has a friendly voice and can speak twelve languages. The battery lasts for twenty hours. We are very proud of this invention. Thank you for listening.",
    "g7m2": "Studying abroad is a great experience. Last year, I went to a high school in Canada for six months. At first, I was nervous because my English was not perfect. But my host family was very kind. They helped me with homework and took me to beautiful places. I made many friends from different countries. Now, my English is much better and I understand Canadian culture. I recommend every student to try it!",
    "g7m3": "Our city council has a new plan to make our town eco-friendly. First, we will plant one thousand trees along the main roads. Second, all buses will use electric power instead of diesel. Third, every house must recycle plastic, paper, and glass. The mayor says these changes will make our air cleaner and our city greener. We hope to finish the plan by next summer.",
    "g7m4": "Online learning has become very popular. During the COVID-19 pandemic, my school moved all classes to the internet. We used video calls and digital textbooks. Some students liked it because they could study at their own pace. Others missed their friends and found it hard to concentrate at home. In my opinion, online learning is useful, but it cannot replace real classrooms completely.",
    
    # G7 Final
    "g7f1": "Space travel has always fascinated humans. In 1969, Neil Armstrong became the first person to walk on the moon. Since then, scientists have built space stations and sent robots to Mars. Now, private companies like SpaceX want to send tourists to space. Tickets will cost about two hundred thousand dollars. I dream of visiting the International Space Station one day. But first, I need to save a lot of money!",
    "g7f2": "Ancient civilizations were amazing. The Egyptians built huge pyramids without modern machines. The Greeks invented democracy and wrote famous plays. The Romans built roads and bridges that still stand today. These ancient people did not have computers or electricity, but they created things that lasted for thousands of years. We can learn a lot from their creativity and hard work.",
    "g7f3": "In the future, technology will change our lives in many ways. Doctors will use robots to do surgery. Cars will drive themselves. Computers will understand human emotions. Some scientists say we will live to be one hundred and fifty years old. But there are also risks. If robots take too many jobs, many people will be unemployed. We must plan carefully for this future.",
    "g7f4": "Scientists have discovered that some animals are very intelligent. Dolphins can understand sign language and solve problems. Elephants remember friends they met twenty years ago. Crows use tools to get food. Octopuses can open jars and escape from tanks. These animals show that intelligence is not only a human quality. We should respect all living creatures and protect their habitats.",
    
    # G8 Mock
    "g8m1": "Ladies and gentlemen, welcome to tonight's performance of Romeo and Juliet by William Shakespeare. This classic tragedy tells the story of two young lovers from rival families in Verona. Our director, Ms. Zhang, has set the play in modern-day Shanghai to make it more relatable. The cast has rehearsed for three months. Please turn off your mobile phones. The show begins in five minutes. Enjoy the performance!",
    "g8m2": "Climate change is the biggest problem facing our planet. The Earth's temperature has risen by one degree Celsius since the year nineteen hundred. This causes melting ice, rising sea levels, and extreme weather. Many countries have promised to reduce carbon emissions, but progress is slow. Experts say we must act within ten years to avoid the worst effects. Everyone can help by using less energy and eating less meat.",
    "g8m3": "Artificial intelligence is transforming many industries. AI can diagnose diseases, translate languages, and even write music. But there are serious concerns. Some people worry that AI will replace human workers. Others fear that biased algorithms will discriminate against minorities. My view is that we need strong laws to control AI development. Technology should serve humanity, not control it.",
    "g8m4": "Yesterday, I attended a meeting in a big boardroom where an entrepreneur presented her new marketing plan. She wanted to launch a line of accessories — earrings, necklaces, and bracelets made from recycled materials. First, she explained that her team needed to check the supply and demand before production. They shopped around for the best material prices and used crowdsourcing to ask consumers about their favourite colours. The community voted online, and the winning colours were blue and green. The entrepreneur expected a fifty percent revenue increase and a solid profit within six months. Finally, her designer submitted a beautiful bracelet design to the boardroom for approval. Everyone agreed it was an incredibly smart plan.",
    
    # G8 Final
    "g8f1": "Last month, a famous designer launched a new line of necklaces and bracelets. The products were made from expensive materials including gold and silver. The company held a meeting in a large boardroom to discuss their expected profit. Everyone agreed the designs were incredibly beautiful.",
    "g8f2": "Last week, a young entrepreneur wanted to invest in a new accessories business. She needed to check supply and demand before spending money on materials. Her marketing team planned to increase revenue by selling products online to reach more consumers. The budget meeting was held in a small boardroom with five investors. The outcome was positive — they agreed to give her ten thousand dollars to start. The consumers who tested her sample products said the brand was incredibly stylish and the prices were fair.",
    "g8f3": "The Silk Road was not used by the Roman Dynasty — it was established during the Han Dynasty in China. Traders transported goods by land and sea along ancient trade routes, carrying silk, spices, and jewellery between civilizations. Ancient trading practices had a huge impact on modern business — many of today's companies still use similar transport and exchange methods. The profit from silk trade was incredibly high for successful traders, though many faced dangers on the road. Merchants established trading companies and communities along the main routes, creating a network that lasted for centuries.",
    "g8f4": "Last year, a group of young entrepreneurs organized a community business project in a small town. They taught local people how to make bead earrings and recycled accessories from old materials. The community used crowdsourcing online to vote on new designs every month. The expected outcome was to increase local profit and revenue so that families could earn extra income. At the final meeting, the designer submitted a new product design for approval — a bracelet made from recycled glass beads. The project was incredibly successful and now exports to three nearby cities."
}

# Voice mapping — British English Neural voices
# Odd tracks = Male, Even tracks = Female
VOICE_MAP = {
    'm': 'en-GB-RyanNeural',
    'f': 'en-GB-SoniaNeural',
}

async def generate_audio(key, text):
    """Generate MP3 using Edge TTS."""
    output_file = OUTPUT_DIR / f"{key}.mp3"
    
    if output_file.exists():
        print(f"Skipping {key} — already exists")
        return
    
    # Detect gender from track number
    gender = 'm' if int(key[-1]) % 2 == 1 else 'f'
    voice = VOICE_MAP[gender]
    
    print(f"Generating {key}... ({len(text)} chars) — Voice: {voice}")
    
    communicate = edge_tts.Communicate(text, voice)
    await communicate.save(str(output_file))
    
    size_kb = output_file.stat().st_size / 1024
    print(f"  ✓ {key}.mp3 — {size_kb:.1f} KB")

async def main():
    total_chars = sum(len(t) for t in SCRIPTS.values())
    print(f"Total characters: {total_chars:,}")
    print(f"Output: {OUTPUT_DIR.absolute()}")
    print("-" * 50)
    
    for key, text in SCRIPTS.items():
        await generate_audio(key, text)
    
    print("-" * 50)
    print("Done! Files saved to:", OUTPUT_DIR)
    print("\nNext steps:")
    print("1. Review the MP3s for quality")
    print("2. Upload to GitHub Release: listening-practice-v1")
    print("3. Test at https://0604.ai/output/listening-practice-g6-g8.html")

if __name__ == '__main__':
    asyncio.run(main())
