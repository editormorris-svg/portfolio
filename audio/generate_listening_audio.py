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
    "g6f1": "Last Saturday, I watched a series on TV about a famous millionaire who loved helping people. One day, he decided to reach out to a local school and give the students a special gift. At the school, the teachers noticed a big smile on every child's face when they saw the surprise. The millionaire organized a fun quiz for the whole audience of students and parents. During the show, a little girl started to cough because she drank her juice too fast, but her friend quickly helped her. The millionaire told everyone that being kind has nothing to do with having money — it has nothing to do with being rich or poor. At the end of the day, the whole army of happy children thanked him with a big song. Everyone agreed it was the best Saturday ever!",
    "g6f2": "Last month, I watched a fun series about a silly soldier who worked in a big army base. One day, his captain gave him a quiz to test his knowledge, but the soldier was too busy playing games to study. He tried to reach a high point on the climbing wall, but he fell down and made everyone laugh. The captain started to cough because he laughed too hard! The soldier explained that his bad grade had nothing to do with being lazy — it had nothing to do with his effort at all, he said. In the end, a kind millionaire visited the base and gave the silly soldier a second chance to try the quiz again. This time, the soldier studied hard and passed with a big smile!",
    "g6f3": "Last weekend, our school held an exciting running race on the sports field. Thirty students from Grade Six joined the competition. The head teacher gave a short speech before the race started. He said, "Running is not just about speed — it is about trying your best." The track was two hundred metres long, and the runners had to go around it three times. At first, a tall boy called Max was in the lead. But in the final lap, a quiet girl named Lily suddenly ran faster and passed him. The audience cheered loudly when Lily crossed the finish line. She won first place! In her interview after the race, Lily said, "I practise every morning before school. My mother wakes up early to run with me." Everyone clapped for her. The head teacher gave her a gold medal and a new pair of running shoes as prizes.",
    "g6f4": "My uncle Tom works as a waiter in a famous restaurant, and last month he was invited to join a TV game show called Waiter Wars. The show tests waiters from different restaurants on their skills. In the first round, each contestant had to carry five full glasses of water on a tray across a small bridge without spilling any. Two waiters failed and were eliminated. In the second round, the remaining contestants had to memorise a long order from a difficult customer. My uncle remembered every detail — the customer wanted no onions, extra cheese, and the sauce on the side. The host was very impressed. In the final round, Uncle Tom had to set a table for ten people in under three minutes. He finished with ten seconds left! He won the show and received a cheque for five thousand yuan. Now he is the most famous waiter in our city.",
    
    # G7 Mock
    "g7m1": "Are you tired of waiting in long queues at the supermarket? Introducing QuickCart — the new online shopping app that brings fresh food directly to your door! With QuickCart, you can browse over ten thousand products from local farms and international brands. Our special feature? Same-day delivery before six p.m. if you order before noon. New users get a twenty percent discount on their first three orders. Plus, every purchase earns you points towards free delivery. Download QuickCart today and use code FRESH20 at checkout. Shopping has never been this easy. QuickCart — fresh, fast, and fantastic.",
    "g7m2": "Good afternoon, and thank you for joining our campaign launch for Ocean Breeze Restaurant. As you know, Ocean Breeze has served fresh seafood in this harbour for twenty years. This summer, we are starting a new campaign called "Dine and Donate." Here is how it works: for every meal you order, we will donate one dollar to the Ocean Protection Fund. Our goal is to collect fifty thousand dollars by the end of August. We have also redesigned our menu with more vegetarian options to reduce our carbon footprint. Our chef, Maria Chen, has created five new plant-based dishes that even meat-lovers enjoy. Visit us this weekend for a tasting event. Together, we can enjoy great food and protect our oceans at the same time.",
    "g7m3": "Welcome to the launch of our new fashion brand, GreenThread. At GreenThread, we believe style should not harm the planet. All our clothes are made from one hundred percent organic cotton and recycled materials. Our factory uses solar power, and we never use plastic packaging. This season, we are introducing three product lines: Urban Casual, Office Smart, and Weekend Adventure. Prices range from one hundred and fifty to six hundred yuan. Our bestselling item so far is the bamboo-fibre jacket — it is waterproof, breathable, and completely biodegradable. Visit our website or our flagship store on Nanjing Road. Remember: when you wear GreenThread, you wear the future.",
    "g7m4": "Hello, I am James Liu, CEO of BrightTech Solutions. Today, I am proud to announce our newest product: the SmartPen. The SmartPen looks like an ordinary pen, but it can do extraordinary things. First, it records everything you write and saves it to the cloud automatically. Second, it translates your handwriting into typed text in over forty languages. Third, it has a built-in microphone that records lectures while you take notes. The battery lasts for one week on a single charge. We are offering the SmartPen at an introductory price of four hundred and ninety-nine yuan until the end of this month. After that, the price will increase to six hundred and ninety-nine yuan. Pre-order now on our website and receive a free leather case.",
    
    # G7 Final
    "g7f1": "Good morning, everyone, and thank you for coming to the opening of PageTurner Bookshop. I am Sarah Wang, the owner. After ten years of working in publishing, I finally opened my own store. PageTurner is not just a bookshop — it is a community space. We have a reading corner with comfortable sofas, a small café serving local coffee, and a weekly story-time session for children every Saturday morning. Our special section features books by local authors, and we host monthly meet-and-greet events where readers can talk directly to writers. Today, all books are twenty percent off, and the first fifty customers receive a free canvas bag. Come in, find a book, and make yourself at home.",
    "g7f2": "Welcome back to TechTalk Weekly. Today, I am reviewing the new Lumina X7 camera, which has just entered the market at a price of three thousand, two hundred yuan. The Lumina X7 has a forty-megapixel sensor and can record video in four-K resolution. I tested it over the weekend at a football match and a concert. The photos were sharp even when I zoomed in fully. The video stabilisation is excellent — I ran while filming, and the footage stayed smooth. However, there are two drawbacks. First, the battery only lasts for about four hours of continuous use. Second, the menu system is confusing for beginners. Overall, I give the Lumina X7 a rating of eight out of ten. It is a great choice for amateur photographers who want professional results without paying professional prices.",
    "g7f3": "Hi, I am Olympic runner Zhang Mei, and I am here to tell you about my favourite training partner: the SpeedStar running shoe. I have worn SpeedStar shoes for three years, and they have never let me down. The special feature is the air-cushion technology that protects your knees when you run on hard roads. The shoes are also extremely light — each one weighs less than two hundred grams. This season, SpeedStar is launching a new colour collection: Midnight Black, Ocean Blue, and Sunset Orange. For every pair sold, SpeedStar will plant one tree through their partnership with GreenEarth Foundation. Use my code ZHANGMEI15 for fifteen percent off your first order. Remember: the right shoes do not just carry you — they protect you.",
    "g7f4": "Are you still struggling with your old kitchen blender that leaves chunks of fruit in your smoothie? Meet the BlendPro 3000 — the most powerful home blender on the market. With its two-thousand-watt motor and six stainless-steel blades, the BlendPro 3000 can crush ice, nuts, and frozen fruit in just ten seconds. The jug is made from unbreakable glass and holds up to two litres. Cleaning is easy — just add water and a drop of soap, press the auto-clean button, and it cleans itself in thirty seconds. The BlendPro 3000 comes in three colours: silver, red, and black. Order before the end of the month and receive a free recipe book with fifty healthy smoothie ideas. BlendPro 3000 — smooth results, every time.",
    
    # G8 Mock
    "g8m1": "At only seventeen years old, Lin Yue has already started two successful businesses. Her first venture was a tutoring app that connected high school students with university tutors for online help. She built the app herself using free online courses and launched it with just five thousand yuan of savings. Within six months, the app had over ten thousand users. Her second business is even more innovative. Lin noticed that many students in rural areas could not afford expensive textbooks, so she created a book-sharing platform where city students donate used books to rural schools. The platform now operates in twelve provinces and has donated over fifty thousand books. Lin believes that young people should not wait until they graduate to start making a difference. "Age is not a barrier," she says. "Creativity and courage are what matter."",
    "g8m2": "A new shoe company called SoleShare is changing how footwear is designed and sold. Instead of employing its own designers, SoleShare invites customers to submit design ideas through its website. Every month, the company selects five designs from the public and puts them to a vote. The winning design goes into production, and the creator receives five percent of the profits. This crowdsourcing model has been surprisingly successful. Last year, SoleShare sold over two hundred thousand pairs of shoes worldwide. The company's CEO, Marcus Webb, explains the philosophy behind the model: "Traditional shoe companies tell customers what to wear. We let customers tell us what they want." The average price of a SoleShare shoe is three hundred yuan — lower than most designer brands because there is no expensive design team. Customers seem happy with the arrangement. Seventy-eight percent of buyers say they would purchase from SoleShare again.",
    "g8m3": "The ancient Silk Road was not a single road but a vast network of trade routes connecting China to Europe. Active from around the second century BC to the fifteenth century AD, the Silk Road stretched over six thousand four hundred kilometres at its longest point. Merchants travelled in caravans carrying silk, spices, porcelain, and tea westward, while wool, glass, and gold moved eastward. But the Silk Road was more than a trading route. It was also a channel for cultural exchange. Buddhism travelled from India to China along these paths. Chinese paper-making technology reached Europe through Muslim traders. Languages blended at oasis towns where travellers rested. The Silk Road declined when maritime trade became cheaper and faster in the fifteenth century. However, its legacy lives on today in the modern Belt and Road Initiative, which aims to build new trade connections between Asia and Europe using railways and ports rather than camel caravans.",
    "g8m4": "Good morning, team. Today, I am presenting our marketing plan for the next quarter. Our main product is the EcoBottle — a reusable water bottle made from recycled ocean plastic. Our target customers are university students and young professionals aged eighteen to thirty. Our primary goal is to increase brand awareness by forty percent before December. Here is our three-part strategy. First, social media. We will partner with twenty fitness influencers on Douyin and Xiaohongshu to create short videos showing the EcoBottle in daily use. Second, campus events. We will sponsor five university sports competitions and give free EcoBottles to participants. Third, a charity angle. For every bottle sold, we will remove one kilogram of plastic from the ocean through our partnership with OceanClean. Our total budget for this campaign is two hundred thousand yuan. I believe this plan will position EcoBottle as the top eco-friendly brand for young consumers.",
    
    # G8 Final
    "g8f1": "In the world of luxury jewellery, few names are as respected as Elena Voss. Born in a small village in Germany, Voss started making jewellery at the age of twelve using beads and wire from her father's workshop. Today, at forty-five, she runs an international brand with stores in Paris, Tokyo, and Shanghai. What makes her designs special is her commitment to ethical sourcing. Every diamond in her collection is certified conflict-free, and all gold is recycled from old electronics. Her most famous piece, the Ocean Wave necklace, took six months to create and sold at auction for two million euros. Despite her success, Voss still designs every piece herself. "I cannot trust a computer to feel emotion," she says. "Jewellery should tell a story, and only a human heart can write that story." Her next collection will feature jade from Xinjiang, combined with traditional Chinese knotting techniques — a bridge between European design and Asian craftsmanship.",
    "g8f2": "Welcome to Finance Basics, episode twelve. Today, we are discussing how to create a personal investment budget. An investment budget is different from a normal savings plan because it allocates money specifically for assets that may grow in value, such as stocks, bonds, or property. Financial advisor Chen Wei recommends the fifty-thirty-twenty rule. Fifty percent of your income goes to necessities like rent and food. Thirty percent goes to wants like entertainment and travel. Twenty percent goes to investments. Within that twenty percent, Chen suggests dividing it further: forty percent into low-risk options like government bonds, forty percent into medium-risk options like index funds, and twenty percent into higher-risk options like individual stocks or start-up investments. "Never invest money you cannot afford to lose," Chen warns. He also recommends reviewing your investment budget every six months and adjusting based on market conditions and personal goals. Remember: investing is a marathon, not a sprint.",
    "g8f3": "Before modern banking existed, ancient civilisations developed surprisingly sophisticated trade systems. In Mesopotamia around three thousand BC, merchants used clay tablets as receipts and contracts. These tablets recorded the quantity of goods, the names of traders, and the date of transaction — essentially the world's first written business documents. The Phoenicians, who lived along the coast of modern-day Lebanon, created a network of trading colonies stretching from Spain to North Africa. They introduced the alphabet to many regions primarily so they could keep better business records. In China, the Han Dynasty developed a system of government-run warehouses where merchants could deposit goods and receive certificates of value. These certificates could be traded like money, making long-distance commerce much safer. Perhaps most remarkably, the ancient Indians developed the concept of interest on loans by around six hundred BC. The standard rate was typically fifteen percent per year — remarkably similar to modern credit card rates.",
    "g8f4": "In the spring of two thousand twenty-four, a group of secondary school students in Chengdu started a community project that has since become a model for other cities. The project, called Green Alley, began when the students noticed that the narrow alley behind their school was filled with rubbish and smelled terrible. Instead of complaining, they decided to transform it. First, they organised a weekend clean-up event and collected over two thousand kilograms of waste. Then, they convinced local artists to paint colourful murals on the walls. Next, they built wooden planters from recycled pallets and filled them with flowers and herbs. Finally, they installed solar-powered lights so the alley would be safe at night. The result? What was once an ugly rubbish dump is now a beautiful community space where neighbours meet, children play, and elderly residents enjoy morning tea. The students have presented their project at three education conferences. "We did not ask for permission," says team leader Zhao Wei. "We asked for forgiveness after we had already made the alley beautiful.""
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
