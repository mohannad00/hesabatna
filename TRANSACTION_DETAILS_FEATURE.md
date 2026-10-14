# Transaction Details Feature

## Overview
The Transaction Details Bottom Sheet provides a comprehensive breakdown of financial transactions between two members in a group. This feature shows detailed calculations explaining why one person owes another money or why money is owed to them.

## How to Access
1. Navigate to a group detail screen
2. Go to the "Members" tab  
3. Click on any member to view their details
4. In the member detail screen, you'll see:
   - **"To Receive"** section - money others owe to this member
   - **"To Pay"** section - money this member owes to others
5. **Click on any person name/amount** in either section to open the detailed explanation

## What the Bottom Sheet Shows

### 1. Net Balance Card (Top)
- Shows the final amount between the two people
- Indicates who owes whom and how much
- Color-coded: Green (money to receive), Red (money to pay), Gray (settled up)

### 2. Calculation Breakdown
- **[Person A] owes [Person B]**: Total amount from expenses where Person B paid and Person A benefited
- **[Person B] owes [Person A]**: Total amount from expenses where Person A paid and Person B benefited  
- **Net Balance**: The final amount after subtracting what each person owes the other

### 3. Detailed Transaction History

#### Expenses Paid by Each Person
- Lists all expenses where one person paid and the other benefited
- Shows:
  - Expense description and date
  - Total expense amount
  - How much the other person owes for this expense
  - Who else shared this expense and their amounts

#### Direct Payments
- Shows any direct payments/settlements between the two people
- Indicates direction (who paid whom)
- Includes payment dates and notes

## Example Calculation

If Alice and Bob are in a group:

**Expenses:**
- Alice paid $30 for dinner, split equally with Bob → Bob owes Alice $15
- Bob paid $20 for groceries, Alice got $8 share → Alice owes Bob $8
- Alice paid $12 for gas, Bob got $6 share → Bob owes Alice $6

**Payments:**
- Bob paid Alice $5 directly

**Calculation:**
- Bob owes Alice: $15 + $6 = $21
- Alice owes Bob: $8
- Payments: Bob paid Alice $5
- Net: Bob owes Alice $21 - $8 - $5 = $8

## Features
- **Responsive Design**: Works on all screen sizes
- **Dark/Light Mode**: Automatically adapts to your theme
- **Scrollable**: Handle long transaction histories
- **Color Coded**: Easy to distinguish between different transaction types
- **Detailed Breakdown**: Shows exactly how calculations are made
- **Date/Time Information**: When each transaction occurred

## Benefits
- **Transparency**: See exactly how balances are calculated
- **Dispute Resolution**: Clear evidence for any disagreements
- **Financial Tracking**: Detailed history of all interactions
- **Trust Building**: Everyone can see the complete picture