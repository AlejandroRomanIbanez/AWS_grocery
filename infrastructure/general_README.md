# Welcome to GroceryMate!

Hey there! This is GroceryMate—a virtual grocery store I built on Amazon Web Services (AWS) using Terraform, a cool tool that automates cloud setups. Think of it like constructing a shop from scratch: rooms, staff, a cashier, storage shelves, and a big sign out front—all coded up and launched in the cloud. I finished this project on February 27, 2025, and it’s been a fun ride!

## What’s GroceryMate All About?

Imagine walking into a grocery store online:
- **The Building:** A private network splits into public areas (where customers arrive) and private backrooms (where the magic happens).
- **The Staff:** Virtual computers run the store’s app, managed by a team leader that keeps the right number of workers on duty.
- **The Cashier:** A traffic director sends customers to available staff smoothly.
- **The Storage:** Shelves hold files like product photos, with one set for the shop’s plans and another for app goodies.
- **The Sign:** A web address points customers right to the front door.

## How It Works

I used Terraform to blueprint this store in AWS:
- **Network:** Set up a big space with public and private zones, connected by doors to the internet and a safe back exit for updates.
- **Computers:** Launched a helper computer to manage things and worker computers to run the app, showing “GroceryMate App Running” to visitors.
- **Traffic:** Added a load balancer to greet customers and share the workload among staff.
- **Database:** Built a secure storage room for orders, with a backup copy just in case.
- **Files:** Created storage buckets—one for my Terraform plans and one for app files, accessible with temporary links.
- **Signage:** Pointed a web address to the cashier so customers can find us.

## What I Tested

On February 27, 2025, I checked it all out:
1. **Logged In:** Popped into the helper computer—no issues!
2. **Database:** Connected to the order storage securely—worked like a charm!
3. **Storage:** Uploaded a test file, grabbed a link, and downloaded it—smooth sailing!
4. **Website:** Visited the store’s address—saw the welcome message loud and clear!
5. **Staff:** Took one worker offline; a new one stepped up—team stayed strong at two!

## Tech Highlights

- **Terraform:** Wrote blueprints (`.tf` files) to automate everything in AWS.
- **AWS Services:** Used a mix of networking, compute, load balancing, database, storage, and naming services.
- **Security:** Locked doors with rules and badges—only the right folks get in.

## What’s Next?

This shop’s open for business! I could tweak the staff size, add more security (like HTTPS), or set up auto-alerts if things get busy. For now, it’s a solid start—ready for customers!

## Want to Peek Inside?

The code’s here in this repo (check the `terraform` branch), but the nitty-gritty details—like exact addresses or keys—are kept local. Feel free to explore the structure and try it out with your own AWS setup!

Happy shopping, and thanks for stopping by!