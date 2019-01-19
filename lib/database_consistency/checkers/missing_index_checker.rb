# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks if association's foreign key has index in the database
    class MissingIndexChecker < AssociationChecker
      # Message templates
      MISSING_INDEX = 'associated model should have proper index in the database'

      private

      # We skip check when:
      #  - association isn't a `HasOne` or `HasMany`
      def preconditions
        [
          ActiveRecord::Associations::HasOneAssociation,
          ActiveRecord::Associations::HasOneThroughAssociation,
          ActiveRecord::Associations::HasManyAssociation,
          ActiveRecord::Associations::HasManyThroughAssociation
        ].include?(association.association_class)
      end

      # Table of possible statuses
      # | index        | status |
      # | ------------ | ------ |
      # | persisted    | ok     |
      # | missing      | fail   |
      def check
        if index
          report_template(:ok)
        else
          report_template(:fail, MISSING_INDEX)
        end
      end

      def index
        @index ||= association.klass.connection.indexes(association.klass.table_name).find do |index|
          index.columns[0] == association.foreign_key.to_s
        end
      end
    end
  end
end
