class DistanceMatrixCache < ActiveRecord::Base

    def self.load source, destination
        distance = self
        .where(source: source)
        .where(destination: destination)
        .where('updated_at >= ?', 1.month.ago)
        .first

        unless distance == nil
            return YAML.load(distance.result)
        else
            return nil
        end
    end

    def self.save source, destination, result
        old = self.find_by(source: source, destination: destination)
        if old == nil
            cache = self.create(
            source: source,
            destination: destination,
            result: YAML.dump(result)
            )
            cache.save
        else
            old.result = YAML.dump(result)
            old.save
        end
    end

end
