# Hesabatna v2 - Quick Reference Guide

## 🚀 Getting Started (3 Steps)

```bash
1. flutter pub get
2. flutter run
3. Start tracking expenses!
```

## 📱 Common Operations

### Create Your First Group
```
Home Screen → Tap "New Group" → Enter name → Create
```

### Add Members to Group
```
Open Group → Menu (⋮) → Add Member → Enter name → Add
(Repeat for all members)
```

### Record an Expense
```
Group Screen → Tap + Button → Fill in:
  - Description: "Lunch"
  - Amount: 90
  - Paid by: Select member
  - Split: Choose Equal or Custom
  - Select beneficiaries
→ Add Expense
```

### Record a Settlement
```
Group Screen → Tap "Settle" → Fill in:
  - From: Person paying
  - To: Person receiving
  - Amount: How much
→ Record Settlement
```

### View Who Owes What
```
Group Screen → Summary Tab
(Green = money to receive, Red = money to pay)
```

### View Member Details
```
Group Screen → Tap member's tab
(See their balance, expenses paid, settlements)
```

### Export Reports
```
Group Screen → Menu (⋮) → Export PDF or Export JSON
```

## 💡 Pro Tips

### Understanding Balances
- **Positive Balance (+)**: Others owe this person money
- **Negative Balance (-)**: This person owes money to others
- **Zero (0)**: All settled up!

### Split Methods
- **Equal Split**: Divides amount equally (easiest)
- **Custom Split**: Specify exact amounts (for unequal splits)

### Suggested Settlements
The Summary tab shows the **minimum transactions** needed to settle all debts.

Example:
- Instead of: A→B ($50), B→C ($50), C→A ($50)
- App suggests: A→C ($50) (one transaction!)

## 🎯 Common Scenarios

### Scenario 1: Shared Dinner
```
1. One person paid for everyone
   → Add Expense
   → Paid by: Ahmed
   → Split: Equal
   → Select all diners
   
2. View Summary to see who owes Ahmed
```

### Scenario 2: Groceries with Unequal Split
```
1. Add Expense
   → Paid by: Sara
   → Split: Custom
   → Enter specific amounts for each person
   
2. Ensure custom amounts add up to total
```

### Scenario 3: Settling Up
```
1. Check Summary tab for who owes whom
2. After payment made in real life:
   → Tap "Settle"
   → From: Person who paid
   → To: Person who received
   → Amount: What was paid
```

### Scenario 4: Trip with Multiple Expenses
```
Day 1: Hotel (Ahmed pays)
Day 2: Food (Sara pays)
Day 3: Transport (Ali pays)

At end of trip:
→ Check Summary for net balances
→ Use Suggested Settlements for easiest way to settle
```

## 🔧 Keyboard Shortcuts (Desktop)

- `Esc` - Close dialog/modal
- `Enter` - Submit form (when focus on button)

## 📊 Understanding the Tabs

### Summary Tab
- **Net Balances**: Overall who owes whom
- **Suggested Settlements**: Minimum transactions to settle all debts

### Member Tabs
Each member has their own tab showing:
- **Net Balance**: Their total balance
- **Balances with Members**: Breakdown per person
- **Expenses Paid**: What they paid for
- **Settlements**: Payments made/received

## ⚠️ Important Notes

### Before Deleting
- **Delete Member**: Only if they have no transactions
- **Delete Group**: Deletes ALL expenses and settlements
- **Delete Expense**: Automatically recalculates balances

### Editing
- Can edit group name and currency anytime
- Can edit member names anytime
- Can edit/delete expenses anytime

### Export
- **PDF**: Human-readable report (for sharing)
- **JSON**: Machine-readable backup (for archiving)

## 🐛 Troubleshooting

### "No members available"
→ Add members to the group first (Menu → Add Member)

### "Custom split total must equal expense amount"
→ When using Custom split, ensure all amounts add up to the total expense

### Balance seems wrong
→ Check all expenses and settlements in member tabs
→ Remember: Positive = money owed TO them, Negative = money owed BY them

### Export not working
→ Grant storage permission when prompted
→ Check device storage space

## 📱 Device Storage

### Where is data stored?
- All data is stored **locally** on your device
- Uses Hive database (efficient NoSQL storage)
- No cloud backup (100% offline)

### Backup Your Data
```
Export to JSON → Save file to cloud storage manually
(Google Drive, Dropbox, etc.)
```

### Clear All Data
```
Uninstall app → Reinstall
(Warning: This deletes everything!)
```

## 🎨 UI Color Guide

- **Teal/Blue**: Primary actions and navigation
- **Green**: Money owed to you / Positive balance
- **Red**: Money you owe / Negative balance
- **Grey**: Neutral / Settled / No balance
- **Orange/Amber**: Warnings and confirmations

## ⌨️ Input Tips

### Amount Fields
- Use decimal point: `12.50`
- No need for currency symbol
- Must be positive number

### Date Fields
- Tap to open calendar picker
- Defaults to today
- Can select past or future dates

### Notes Fields
- Optional but helpful
- Good for: "Bank transfer", "Cash", "Partial payment"

## 📈 Best Practices

1. **Add members first** before recording expenses
2. **Use clear descriptions** for expenses (e.g., "Dinner at Pizza Place" not just "Food")
3. **Record settlements immediately** after real-life payments
4. **Export regularly** to keep backups
5. **Use custom split** when expenses aren't equal
6. **Check suggested settlements** before making multiple payments

## 🎯 Example Workflow

**Weekend Trip with Friends:**

```
Friday:
1. Create group "Weekend Trip - Dec 2024"
2. Add members: Ahmed, Sara, Ali, Fatima

Saturday:
3. Add expense: "Hotel" - Ahmed paid 400 (equal split)
4. Add expense: "Breakfast" - Sara paid 80 (equal split)
5. Add expense: "Lunch" - Ali paid 120 (equal split)

Sunday:
6. Add expense: "Dinner" - Fatima paid 200 (equal split)
7. Check Summary tab → See net balances

After trip:
8. Use Suggested Settlements to settle up
9. Record actual payments made
10. Verify everyone is at $0 balance
11. Export PDF as trip record
```

## 💬 Need Help?

1. Check the **README.md** for detailed explanations
2. Check the **SETUP.md** for technical issues
3. Review this Quick Reference for common tasks

---

**Happy Expense Tracking! 📊✨**

*Tip: Bookmark this page for quick access to common operations*

