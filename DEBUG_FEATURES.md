# Debug & Testing Features

## Overview
The Hesabatna app includes comprehensive debugging and testing tools to help developers and testers work with sample data.

## Auto-Initialize Debug Data
- **When**: App automatically adds sample data on first run in debug mode
- **Condition**: Only if no groups exist in the database
- **Content**: 3 complete groups with members, expenses, and payments

## Manual Debug Controls
Access debug controls through: **Profile → Debug & Testing**

### Available Actions

#### 1. Add Complete Test Data
Creates 3 comprehensive test groups:

**🏖️ Dubai Trip 2024**
- 4 members: Alice Johnson, Bob Smith, Charlie Brown, Diana Prince
- 7 expenses: flights, hotel, dinners, activities, car rental
- 2 settlement payments
- Complex splitting scenarios
- Currency: AED

**💼 Office Team Lunches**
- 3 members: John Doe, Sarah Wilson, Mike Davis
- 3 lunch expenses with equal splits
- 1 settlement payment
- Currency: USD

**👨‍👩‍👧‍👦 Family Weekend Trip**
- 4 family members: Dad, Mom, Emma (16), Max (14)
- 5 expenses with custom splits (parents pay for some, kids contribute to others)
- 1 family payment
- Currency: USD

#### 2. Add Quick Test Group
- Creates a simple 2-member group for rapid testing
- 1 basic expense split equally
- Minimal data for quick functionality tests

#### 3. Clear All Data
- **⚠️ WARNING**: Permanently deletes ALL data
- Requires confirmation dialog
- Removes all groups, members, expenses, and payments

## Sample Data Scenarios

### Transaction Complexity Examples

**Dubai Trip** demonstrates:
- Multi-member expense splitting
- Different payers for different expenses
- Settlement payments between members
- International currency (AED)
- Various expense types (travel, accommodation, food, entertainment)

**Office Lunches** demonstrates:
- Simple equal splits
- Regular recurring expenses
- Small group dynamics
- Basic settlement patterns

**Family Trip** demonstrates:
- Custom split scenarios
- Age-based contribution differences
- Parent-child financial relationships
- Mixed payment responsibilities

## Testing the Transaction Details Feature

The debug data is specifically designed to test the **Transaction Details Bottom Sheet**:

1. Navigate to any group
2. Go to Members tab
3. Click on any member
4. Click on any balance item (person name/amount) in "To Receive" or "To Pay" sections
5. Review the detailed breakdown showing:
   - Net balance calculation
   - Individual expense contributions
   - Settlement payment history
   - Complete transaction timeline

## Best Practices

### For Developers
- Use "Add Complete Test Data" for full feature testing
- Use "Quick Test Group" for rapid iteration
- Clear data between major test scenarios
- Check both light and dark themes with sample data

### For Testers
- Test all user flows with pre-populated data
- Verify calculations using the Transaction Details feature
- Test edge cases like zero balances and complex splits
- Validate currency formatting and date displays

### For Demos
- Use complete test data to showcase app capabilities
- Dubai Trip group shows international usage
- Family group demonstrates custom splitting
- Office group shows simple business use case

## Debug Safety
- Debug data only auto-loads in development builds
- Production builds will never auto-populate data
- Clear data function includes safety confirmation
- All debug features are clearly marked with 🧪 icons

## Troubleshooting
If debug data doesn't appear:
1. Ensure app is running in debug mode
2. Check that database is empty (no existing groups)
3. Try manual "Add Complete Test Data" from Profile → Debug & Testing
4. Clear all data and restart app if needed